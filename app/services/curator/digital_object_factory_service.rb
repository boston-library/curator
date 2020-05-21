# frozen_string_literal: true

module Curator
  class DigitalObjectFactoryService < Services::Base
    include Services::FactoryService
    include DescriptiveComplexAttrs

    # TODO: set relationships for contained_by values
    def call
      with_transaction do
        admin_set_ark_id = @json_attrs.dig('admin_set', 'ark_id')
        collection_ark_ids = @json_attrs.fetch('is_member_of_collection', []).pluck('ark_id')
        @record = Curator.digital_object_class.where(ark_id: @ark_id).first_or_create! do |digital_object|
          admin_set = find_admin_set!(admin_set_ark_id, digital_object)
          digital_object.admin_set = admin_set
          digital_object.created_at = @created if @created
          digital_object.updated_at = @updated if @updated

          find_or_build_collection_members!(digital_object, admin_set_ark_id, collection_ark_ids)

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
            descriptive.cartographic = cartographic(@desc_json_attrs)
            descriptive.related = related(@desc_json_attrs)
            %w(genres resource_types languages).each do |map_type|
              @desc_json_attrs.fetch(map_type, []).each do |map_attrs|
                mapped_term = term_for_mapping(map_attrs,
                                               nomenclature_class: Curator.controlled_terms.public_send("#{map_type.singularize}_class"))
                descriptive.desc_terms.build(mapped_term: mapped_term)
              end
            end
            @desc_json_attrs.fetch(:host_collections, []).each do |host_col|
              next if admin_set.blank?

              host_col = find_or_create_host_collection(host_col,
                                                        admin_set.institution)
              descriptive.desc_host_collections.build(host_collection: host_col)
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

    def find_or_build_collection_members!(digital_object, admin_set_ark_id, collection_ark_ids = [])
      return if collection_ark_ids.blank?

      collection_ark_ids.each do |collection_ark_id|
        begin
          next if collection_ark_id == admin_set_ark_id

          collection = Curator.collection_class.select(:id, :ark_id).find_by!(ark_id: collection_ark_id)

          next if digital_object.collection_members.exists?(collection: collection)

          digital_object.collection_members.build(collection: collection)
        rescue ActiveRecord::RecordNotFound => e
          digital_object.errors.add(:collection_members, "#{e.message} with ark id=#{collection_ark_id}")
          raise ActiveRecord::RecordInvalid, digital_object
        end
      end
    end

    def find_admin_set!(admin_set_ark_id, digital_object)
      return Curator.collection_class.find_by!(ark_id: admin_set_ark_id)
    rescue ActiveRecord::RecordNotFound => e
      digital_object.errors.add(:admin_set, "#{e.message} with ark_id=#{admin_set_ark_id}")
      nil
    end

    def find_or_create_host_collection(host_col_name = nil, institution = nil)
      return if host_col_name.blank? || institution.blank?

      retries = 0
      begin
        return Curator.mappings.host_collection_class.transaction(requires_new: true) do
          institution.host_collections.name_lower(host_col_name).first || institution.host_collections.create!(name: host_col_name)
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
