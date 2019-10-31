# frozen_string_literal: true

module Curator
  class ObjectFactoryService < Services::Base
    include Services::FactoryService

    # TODO set relationships for is_issue_of values
    def call
      admin_set_ark_id = @json_attrs.dig('admin_set', 'ark_id')
      begin
        Curator.digital_object_class.transaction do
          admin_set = Curator.collection_class.find_by(ark_id: admin_set_ark_id)
          raise "AdminSet #{admin_set_ark_id} not found!" unless admin_set

          digital_object = Curator.digital_object_class.new(ark_id: @ark_id)
          digital_object.admin_set = admin_set
          collections = @json_attrs.fetch('exemplary_image_of', [])
          collections.each do |collection|
            col_ark_id = collection['ark_id']
            col = Curator.collection_class.find_by(ark_id: col_ark_id)
            raise "Collection #{col_ark_id} not found!" unless col

            digital_object.is_member_of_collection << col
          end
          digital_object.created_at = @created if @created
          digital_object.updated_at = @updated if @updated
          digital_object.save!

          build_workflow(digital_object) do |workflow|
            [:ingest_origin, :processing_state, :publishing_state].each do |attr|
              workflow.send("#{attr}=", @workflow_json_attrs.fetch(attr, nil))
            end
          end

          build_administrative(digital_object) do |admin|
            [:description_standard, :flagged, :destination_site, :harvestable].each do |attr|
              admin.send("#{attr}=", @admin_json_attrs.fetch(attr, nil))
            end
          end

          build_descriptive(digital_object) do |descriptive|
            simple_fields = %i[abstract access_restrictions digital_origin frequency
                               issuance origin_event extent physical_location_department
                               physical_location_shelf_locator place_of_publication
                               publisher rights series subseries toc toc_url
                               resource_type_manuscript text_direction]
            simple_fields.each do |attr|
              descriptive.send("#{attr}=", @desc_json_attrs.fetch(attr, nil))
            end
            descriptive.identifier = identifier(@desc_json_attrs)
            descriptive.physical_location = physical_location(@desc_json_attrs)
            descriptive.date = date(@desc_json_attrs)
            descriptive.publication = publication(@desc_json_attrs)
            descriptive.title = title(@desc_json_attrs)
            descriptive.note = note(@desc_json_attrs)
            descriptive.subject_other = subject_other(@desc_json_attrs)
            descriptive.cartographic = cartographics(@desc_json_attrs)
            descriptive.related = related(@desc_json_attrs)
            %w(genres resource_types languages).each do |map_type|
              @desc_json_attrs.fetch(map_type, []).each do |map_attrs|
                mappable = get_mappable(map_attrs,
                                        nomenclature_class: Curator.controlled_terms.public_send("#{map_type.singularize}_class"))
                descriptive.desc_terms << Curator.mappings.desc_term_class.new(mappable: mappable)
              end
            end
            @desc_json_attrs.fetch(:host_collections, []).each do |host_col|
              host = find_or_create_host_collection(host_col,
                                                    admin_set.institution.id)
              descriptive.desc_host_collections.build(host_collection: host)
            end
            licenses = @desc_json_attrs.fetch(:licenses, [])
            licenses.each do |license_attrs|
              descriptive.desc_terms << Curator.mappings.desc_term_class.new(
                mappable: get_mappable(
                  license_attrs,
                  nomenclature_class: Curator.controlled_terms.license_class
                )
              )
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
              unless map_type.blank?
                v.each do |map_attrs|
                  descriptive.desc_terms << Curator.mappings.desc_term_class.new(mappable:
                    get_mappable(map_attrs,
                                 nomenclature_class: Curator.controlled_terms.public_send("#{map_type}_class")))
                end
              end
            end

            @desc_json_attrs.fetch(:name_roles, []).each do |name_role_attrs|
              name_role_attrs = name_role(name_role_attrs.fetch(:name), name_role_attrs.fetch(:role))
              descriptive.name_roles.build(name_role_attrs)
            end
          end
          return digital_object
        end
      rescue => e
        puts e.to_s
      end
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
      %i[edition_name edition_number volume issue_number].each do |k|
        pub_hash[k] = json_attrs.fetch(k, nil)
      end
      Descriptives::Publication.new(pub_hash.compact)
    end

    def title(json_attrs = {})
      primary = json_attrs.fetch(:title_primary, {})
      other = json_attrs.fetch(:title_other, {}).map { |t_attrs| title_attr(t_attrs) }
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
      constituent = json_attrs.fetch(:related_constituent, nil)
      referenced_by_url = json_attrs.fetch(:related_referenced_by_url, [])
      references_url = json_attrs.fetch(:related_references_url, [])
      other_format = json_attrs.fetch(:related_other_format, [])
      review_url = json_attrs.fetch(:related_review_url, [])
      Descriptives::Related.new(constituent: constituent, referenced_by_url: referenced_by_url,
                                references_url: references_url, other_format: other_format,
                                review_url: review_url)
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

    def title_attr(json_attrs = {})
      Descriptives::Title.new(json_attrs)
    end

    def cartographics(json_attrs = {})
      Descriptives::Cartographic.new(
        scale: json_attrs.fetch(:scale, []),
        projection: json_attrs.fetch(:projection, nil)
      )
    end

    private

    def get_mappable(json_attrs = {}, nomenclature_class:)
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
      return nil unless host_col_name && institution_id

      begin
        inst = Curator::Institution.find(institution_id)
        raise "Bad institution_id #{institution_id} for host_collection!" if inst.blank?

        return Curator::Mappings.host_collection_class.where(name: host_col_name,
                                                             institution_id: institution_id).first_or_create!
      rescue => e
        puts e.message
      end
      nil
    end
  end
end
