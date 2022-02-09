# frozen_string_literal: true

module Curator
  class DigitalObjectFactoryService < Services::Base
    include Services::FactoryService
    include Metastreams::DescriptiveFieldSetAttrs
    include Mappings::TermMappable
    include Mappings::NameRolable
    include Mappings::FindOrCreateHostCollection
    # TODO: set relationships for contained_by values
    def call
      with_transaction do
        check_for_existing_ark!
        admin_set_ark_id = @json_attrs.dig('admin_set', 'ark_id')
        collection_ark_ids = @json_attrs.fetch('is_member_of_collection', []).pluck('ark_id')
        @record = Curator.digital_object_class.find_or_initialize_by(ark_id: @ark_id).tap do |digital_object|
          admin_set = find_admin_set!(admin_set_ark_id, digital_object)
          digital_object.admin_set = admin_set
          digital_object.created_at = @created if @created
          digital_object.updated_at = @updated if @updated

          find_or_build_collection_members!(digital_object, admin_set_ark_id, collection_ark_ids)

          build_workflow(digital_object) do |workflow|
            workflow.ingest_origin = @workflow_json_attrs.fetch(:ingest_origin, ENV['HOME'].to_s)
            [:processing_state, :publishing_state].each do |attr|
              workflow.send("#{attr}=", @workflow_json_attrs.fetch(attr)) if @workflow_json_attrs.fetch(attr, nil).present?
            end
          end

          build_administrative(digital_object) do |admin|
            [:description_standard, :flagged, :destination_site, :hosting_status, :harvestable, :oai_header_id].each do |attr|
              admin.send("#{attr}=", @admin_json_attrs.fetch(attr)) if @admin_json_attrs.fetch(attr, nil).present?
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
            descriptive.rights_statement = rights_statement(@desc_json_attrs)
            descriptive.date = date(@desc_json_attrs)
            descriptive.publication = publication(@desc_json_attrs)
            descriptive.title = title(@desc_json_attrs)
            descriptive.note = note(@desc_json_attrs)
            descriptive.subject_other = subject_other(@desc_json_attrs)
            descriptive.cartographic = cartographic(@desc_json_attrs)
            descriptive.related = related(@desc_json_attrs)
            %w(genres resource_types languages).each do |map_type|
              mapped_terms = @desc_json_attrs.fetch(map_type, []).map do |map_attrs|
                term_for_mapping(map_attrs, nomenclature_class: Curator.controlled_terms.public_send("#{map_type.singularize}_class"))
              end.compact.delete_if { |mt| !descriptive.new_record? && descriptive.desc_terms.exists?(mapped_term: mt) }

              next if mapped_terms.blank?

              mapped_terms.each { |mt| descriptive.desc_terms.build(mapped_term: mt) }
            end

            host_collections = @desc_json_attrs.fetch(:host_collections, []).uniq.map do |host_col|
              next if admin_set.blank?

              find_or_create_host_collection(host_col, admin_set.institution)
            end.compact.delete_if { |hc| !descriptive.new_record? && descriptive.desc_host_collections.exists?(host_collection: hc) }

            host_collections.each { |hc| descriptive.desc_host_collections.build(host_collection: hc) }

            subject_mapped_terms = terms_for_subject(@desc_json_attrs.fetch(:subject, {})).delete_if { |st| !descriptive.new_record? && descriptive.desc_terms.exists?(mapped_term: st) }
            subject_mapped_terms.each { |smt| descriptive.desc_terms.build(mapped_term: smt) }

            mapped_name_roles = @desc_json_attrs.fetch(:name_roles, []).map do |name_role_attrs|
              name_role(name_role_attrs.fetch(:name), name_role_attrs.fetch(:role))
            end.compact.delete_if { |nr_attrs| !descriptive.new_record? && descriptive.name_roles.exists?(nr_attrs) }

            mapped_name_roles.each { |mnr| descriptive.name_roles.build(mnr) }
          end
          digital_object.save!
        end
      end
      return @success, @result
    end

    private

    def local_id_finder_scope
      admin_set_ark_id = @json_attrs.dig('admin_set', 'ark_id')
      identifier = @desc_json_attrs.fetch(:identifier, [])
      oai_header_id = @admin_json_attrs.fetch(:oai_header_id, nil)

      return if admin_set_ark_id.blank? || (identifier.blank? && oai_header_id.blank?)

      Curator.digital_object_class.local_id_finder(admin_set_ark_id, identifier, oai_header_id)&.first
    end

    def find_or_build_collection_members!(digital_object, admin_set_ark_id, collection_ark_ids = [])
      return if collection_ark_ids.blank?

      collection_ark_ids.each do |collection_ark_id|
        begin
          next if collection_ark_id == admin_set_ark_id

          collection = Curator.collection_class.select(:id, :ark_id).find_by!(ark_id: collection_ark_id)

          next if !digital_object.new_record? && digital_object.collection_members.exists?(collection: collection)

          digital_object.collection_members.build(collection: collection)
        rescue ActiveRecord::RecordNotFound => e
          digital_object.errors.add(:collection_members, "#{e.message} with ark id=#{collection_ark_id}")
          raise ActiveRecord::RecordInvalid, digital_object
        end
      end
    end

    def find_admin_set!(admin_set_ark_id, digital_object)
      return Curator.collection_class.select(:id, :ark_id, :institution_id).find_by!(ark_id: admin_set_ark_id)
    rescue ActiveRecord::RecordNotFound => e
      digital_object.errors.add(:admin_set, "#{e.message} with ark_id=#{admin_set_ark_id}")
      raise ActiveRecord::RecordInvalid, digital_object
    end
  end
end
