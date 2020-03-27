# frozen_string_literal: true

module Curator
  class DigitalObjectFactoryService < Services::Base
    include Services::FactoryService

    # TODO: set relationships for is_issue_of values
    def call
      with_transaction do
        admin_set_ark_id = @json_attrs.dig('admin_set', 'ark_id')
        collection_ark_ids = @json_attrs.fetch('exemplary_image_of', []).pluck('ark_id')
        admin_set = Curator.collection_class.find_by(ark_id: admin_set_ark_id)
        @record = Curator.digital_object_class.where(ark_id: @ark_id).first_or_create! do |digital_object|
          digital_object.admin_set = admin_set
          Curator.collection_class.select(:id, :ark_id).where(ark_id: collection_ark_ids).find_each do |collection|
            digital_object.collection_members.build(collection: collection) unless collection.ark_id == admin_set.ark_id
          end
          digital_object.created_at = @created if @created
          digital_object.updated_at = @updated if @updated

          build_workflow(digital_object) do |workflow|
            [:ingest_origin, :processing_state, :publishing_state].each do |attr|
              workflow.send("#{attr}=", @workflow_json_attrs.fetch(attr, nil))
            end
          end

          build_administrative(digital_object) do |admin|
            [:description_standard, :flagged, :destination_site, :hosting_status, :harvestable].each do |attr|
              admin.send("#{attr}=", @admin_json_attrs.fetch(attr, nil))
            end
          end

          build_descriptive(digital_object) do |descriptive|
            simple_fields = %i(abstract access_restrictions digital_origin frequency
                               issuance origin_event extent physical_location_department
                               physical_location_shelf_locator place_of_publication
                               publisher rights series subseries subsubseries toc toc_url
                               resource_type_manuscript text_direction)
            simple_fields.each do |attr|
              descriptive.send("#{attr}=", @desc_json_attrs.fetch(attr, nil))
            end
            descriptive.resource_type_manuscript ||= false # nil not allowed for this attribute
            descriptive.identifier = identifier(@desc_json_attrs)
            descriptive.physical_location = physical_location(@desc_json_attrs)
            descriptive.license = license(@desc_json_attrs)
            descriptive.date = date(@desc_json_attrs)
            descriptive.publication = publication(@desc_json_attrs)
            descriptive.title = title(@desc_json_attrs)
            descriptive.note = note(@desc_json_attrs)
            descriptive.subject_other = subject_other(@desc_json_attrs)
            descriptive.cartographic = cartographics(@desc_json_attrs)
            descriptive.related = related(@desc_json_attrs)
            %w(genres resource_types languages).each do |map_type|
              @desc_json_attrs.fetch(map_type, []).each do |map_attrs|
                mapped_term = term_for_mapping(map_attrs,
                                               nomenclature_class: Curator.controlled_terms.public_send("#{map_type.singularize}_class"))
                descriptive.desc_terms.build(mapped_term: mapped_term)
              end
            end
            @desc_json_attrs.fetch(:host_collections, []).each do |host_col|
              host = find_or_create_host_collection(host_col,
                                                    admin_set.institution_id)
              descriptive.desc_host_collections.build(host_collection: host)
            end
            @desc_json_attrs.fetch(:subject, {}).each do |k, v|
              map_type = case k.to_s
                         when 'topics'
                           :subject
                         when 'names'
                           :name
                         when 'geos'
                           :geographic
                         end

              next if map_type.blank?

              v.each do |map_attrs|
                mapped_term = term_for_mapping(map_attrs,
                                               nomenclature_class: Curator.controlled_terms.public_send("#{map_type}_class"))
                descriptive.desc_terms.build(mapped_term: mapped_term)
              end
            end

            @desc_json_attrs.fetch(:name_roles, []).each do |name_role_attrs|
              name_role_attrs = name_role(name_role_attrs.fetch(:name), name_role_attrs.fetch(:role))
              descriptive.name_roles.build(name_role_attrs)
            end
          end
        end
      end
      return @success, @result
    end

    def identifier(json_attrs = {})
      json_attrs.fetch(:identifier, []).map do |ident_attrs|
        Descriptives::Identifier.new(ident_attrs)
      end
    end

    def note(json_attrs = {})
      json_attrs.fetch(:note, []).map do |note_attrs|
        Descriptives::Note.new(note_attrs)
      end
    end

    def date(json_attrs = {})
      date_attrs = json_attrs.fetch(:date, {})
      created = date_attrs.fetch(:created, nil)
      issued = date_attrs.fetch(:issued, nil)
      copyright = date_attrs.fetch(:copyright, nil)
      Descriptives::Date.new(created: created, issued: issued, copyright: copyright)
    end

    def publication(json_attrs = {})
      pub_hash = {}
      pub_attrs = json_attrs.fetch(:publication, {})
      %i(edition_name edition_number volume issue_number).each do |k|
        pub_hash[k] = pub_attrs.fetch(k, nil)
      end
      Descriptives::Publication.new(pub_hash.compact)
    end

    def title(json_attrs = {})
      titles = json_attrs.fetch(:title, {})
      primary = titles.fetch(:primary, {})
      other = titles.fetch(:other, {}).map { |t_attrs| title_attr(t_attrs) }
      Descriptives::TitleSet.new(primary: primary, other: other)
    end

    def subject_other(json_attrs = {})
      subject_json = json_attrs.fetch(:subject, {})
      uniform_title = subject_json.fetch(:titles, []).map { |ut_attrs| title_attr(ut_attrs) }
      temporal = subject_json.fetch(:temporals, [])
      date = subject_json.fetch(:dates, [])
      Descriptives::Subject.new(titles: uniform_title, temporals: temporal, dates: date)
    end

    def related(json_attrs = {})
      related_hash = {}
      related_attrs = json_attrs.fetch(:related, {})
      %i(constituent referenced_by_url references_url other_format review_url).each do |k|
        related_hash[k] = related_attrs.fetch(k, nil)
      end
      Descriptives::Related.new(related_hash)
    end

    def physical_location(json_attrs = {})
      physical_location_attrs = json_attrs.fetch(:physical_location)
      authority_code = physical_location_attrs.fetch(:authority_code, nil)
      term_data = physical_location_attrs.except(:authority_code)
      find_or_create_nomenclature(
        nomenclature_class: Curator.controlled_terms.name_class,
        term_data: term_data,
        authority_code: authority_code
      )
    end

    def license(json_attrs = {})
      license_term_data = json_attrs.fetch(:license)
      find_or_create_nomenclature(
        nomenclature_class: Curator.controlled_terms.license_class,
        term_data: license_term_data
      )
    end

    def title_attr(json_attrs = {})
      Descriptives::Title.new(json_attrs)
    end

    def cartographics(json_attrs = {})
      carto_attrs = json_attrs.fetch(:cartographic, {})
      Descriptives::Cartographic.new(
        scale: carto_attrs.fetch(:scale, []),
        projection: carto_attrs.fetch(:projection, nil)
      )
    end

    private

    def term_for_mapping(json_attrs = {}, nomenclature_class:)
      authority_code = json_attrs.fetch(:authority_code, nil)
      term_data = json_attrs.except(:authority_code)
      find_or_create_nomenclature(
        nomenclature_class: nomenclature_class,
        term_data: term_data,
        authority_code: authority_code
      )
    end

    def name_role(name_attrs = {}, role_attrs = {})
      {
        name: find_or_create_nomenclature(
          nomenclature_class: Curator.controlled_terms.name_class,
          term_data: name_attrs.except(:authority_code),
          authority_code: name_attrs.fetch(:authority_code, nil)
        ),
        role: find_or_create_nomenclature(
          nomenclature_class: Curator.controlled_terms.role_class,
          term_data: role_attrs.except(:authority_code),
          authority_code: role_attrs.fetch(:authority_code, nil)
        )
      }
    end

    def find_or_create_host_collection(host_col_name = nil, institution_id = nil)
      return if host_col_name.blank? && institution_id.blank?

      retries = 0
      begin
        return Curator.mappings.host_collection_class.transaction(requires_new: true) do
          inst = Curator.institution_class.find(institution_id)
          inst.host_collections.where(name: host_col_name).first_or_create!
        end
      rescue ActiveRecord::StaleObjectError => e
        if (retries += 1) <= MAX_RETRIES
          Rails.logger.info 'Record is stale retrying in 2 seconds..'
          sleep(2)
          retry
        else
          Rails.logger.error "=================#{e.inspect}=================="
          raise ActiveRecord::RecordNotSaved, "Max retries reached! caused by: #{e.message}", e.record
        end
      end
    end
  end
end
