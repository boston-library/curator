# frozen_string_literal: true

module Curator
  class Metastreams::DescriptiveUpdaterService < Services::Base
    include Services::UpdaterService
    include Metastreams::DescriptiveFieldSetAttrs
    include Mappings::TermMappable
    include Mappings::NameRolable
    include Mappings::FindOrCreateHostCollection

    SIMPLE_ATTRIBUTES_LIST = %i(abstract
                                access_restrictions
                                digital_origin
                                frequency
                                issuance
                                origin_event
                                extent
                                physical_location_department
                                physical_location_shelf_locator
                                place_of_publication
                                publisher
                                rights
                                series
                                subseries
                                subsubseries
                                toc
                                toc_url
                                resource_type_manuscript
                                text_direction).freeze

    JSON_ATTRS = %i(cartographic
                    date
                    identifier
                    note
                    publication
                    related
                    subject_other
                    title).freeze

    TERM_MAPPINGS = %w(genres resource_types languages).freeze

    def call
      with_transaction do
        simple_attributes_update(SIMPLE_ATTRIBUTES_LIST, SIMPLE_ATTRIBUTES_LIST) do |simple_attr|
          # NOTE: see simple_attributes_update in lib/curator/services/updater_service.rb
          # I almost forgot it skips the attribute key if its not detected in the @json_attr hash there

          @record.public_send("#{simple_attr}=", @json_attrs.fetch(simple_attr))
        end

        @record.resource_type_manuscript = @json_attrs.fetch(:resource_type_manuscript, @record.resource_type_manuscript)

        json_attr_update!

        %w(physical_location license rights_statement).each do |term|
          next if is_attr_empty?(term)

          term_json = send(term, @json_attrs)
          @record.public_send("#{term}=", term_json) if term_json && @record.public_send("#{term}_id") != term_json.id
        end

        host_collections_update!
        term_mappings_update!
        name_roles_update!
        subject_update!

        @record.save!
      end

      return @success, @result
    end

    protected

    def term_mappings_update!
      TERM_MAPPINGS.each do |map_type|
        mapped_terms = @json_attrs.fetch(map_type.to_s, [])

        next if mapped_terms.blank?

        terms_to_add = mapped_terms.reject(&SHOULD_REMOVE)
        terms_to_remove = mapped_terms.select(&SHOULD_REMOVE)

        next if terms_to_add.blank? && terms_to_remove.blank?

        add_mapped_terms!(map_type, terms_to_add)

        remove_mapped_terms!(map_type, terms_to_remove)
      end
    end

    def name_roles_update!
      name_role_attrs = @json_attrs.dup.fetch(:name_roles, [])

      return if name_role_attrs.blank?

      name_roles_to_add = name_role_attrs.reject(&SHOULD_REMOVE)
      name_roles_to_remove = name_role_attrs.select(&SHOULD_REMOVE)

      return if name_roles_to_add.blank? && name_roles_to_remove.blank?

      add_name_roles!(name_roles_to_add)
      remove_name_roles!(name_roles_to_remove)
    end

    def subject_update!
      subject_terms = @json_attrs.dup.fetch(:subject, {}).slice(:topics, :names, :geos)

      return if subject_terms.blank?

      terms_to_add = subject_terms.reduce({}) do |ret, (k, v)|
        ret.merge(k => v.reject(&SHOULD_REMOVE))
      end.with_indifferent_access

      terms_to_remove = subject_terms.reduce({}) do |ret, (k, v)|
        ret.merge(k => v.select(&SHOULD_REMOVE))
      end.with_indifferent_access

      return if terms_to_add.blank? && terms_to_remove.blank?

      add_subject_terms!(terms_for_subject(terms_to_add))
      remove_subject_terms!(terms_for_subject(terms_to_remove))
    end

    def json_attr_update!
      JSON_ATTRS.each do |json_attr|
        next if is_attr_empty?(json_attr)

        next if @record.public_send(json_attr).to_json == @json_attrs.fetch(json_attr, {}).to_json

        @record.public_send("#{json_attr}=", send(json_attr, @json_attrs))
      end
    end

    def host_collections_update!
      host_collection_attrs = @json_attrs.fetch(:host_collections, [])

      return if host_collection_attrs.blank?

      host_collections_to_add = host_collection_attrs.reject(&SHOULD_REMOVE)
      host_collections_to_remove = host_collection_attrs.select(&SHOULD_REMOVE)

      return if host_collections_to_add.blank? && host_collections_to_remove.blank?

      add_host_collections!(host_collections_to_add)
      remove_host_collections!(host_collections_to_remove)
    end

    private

    # @param subject_terms [Array[Hash]]
    # @return [NilClass]
    def add_subject_terms!(subject_terms = [])
      return if subject_terms.blank?

      terms_to_add = subject_terms.reject { |st| @record.desc_terms.exists?(mapped_term: st) }

      return if terms_to_add.blank?

      terms_to_add.each { |term_to_add| @record.desc_terms.build(mapped_term: term_to_add) }
    end

    # @param subject_terms [Array[Hash]]
    # @return [NilClass]
    def remove_subject_terms!(subject_terms = [])
      return if subject_terms.blank?

      terms_to_destroy = subject_terms.select { |st| @record.desc_terms.exists?(mapped_term: st) }

      return if terms_to_destroy.blank?

      @record.desc_terms.destroy_by(mapped_term: terms_to_destroy)
    end

    # @param map_type [String]
    # @param mapped_terms Array[Hash]
    def add_mapped_terms!(map_type, mapped_terms = [])
      return if mapped_terms.blank?

      terms_to_add = mapped_terms.map do |map_attrs|
        next if map_attrs.key?(:_destroy)

        term_for_mapping(map_attrs, nomenclature_class: Curator.controlled_terms.public_send("#{map_type.singularize}_class"))
      end.compact.reject { |mt| @record.desc_terms.exists?(mapped_term: mt) }

      return if terms_to_add.blank?

      terms_to_add.each { |term_to_add| @record.desc_terms.build(mapped_term: term_to_add) }
    end

    # @param map_type [String]
    # @param mapped_terms Array[Hash]
    def remove_mapped_terms!(map_type, mapped_terms = [])
      return if mapped_terms.blank?

      terms_to_destroy = mapped_terms.map do |map_attrs|
        next if !map_attrs.key?(:_destroy)

        term_for_mapping(map_attrs.except(:_destroy),
                         nomenclature_class: Curator.controlled_terms.public_send("#{map_type.singularize}_class"))
      end.compact.select { |mt| @record.desc_terms.exists?(mapped_term: mt) }

      return if terms_to_destroy.blank?

      @record.desc_terms.destroy_by(mapped_term: terms_to_destroy)
    end

    # @param name_role_attrs [Array[Hash]]
    def add_name_roles!(name_role_attrs = [])
      return if name_role_attrs.blank?

      mapped_name_roles = name_role_attrs.map do |nr_attrs|
        name_role(nr_attrs.fetch(:name), nr_attrs.fetch(:role))
      end.compact.reject { |mnr_attrs| @record.name_roles.exists?(**mnr_attrs) }

      return if mapped_name_roles.blank?

      mapped_name_roles.each { |mnr| @record.name_roles.build(**mnr) }
    end

    # @param name_role_attrs [Array[Hash]]
    def remove_name_roles!(name_role_attrs = [])
      return if name_role_attrs.blank?

      mapped_name_roles = name_role_attrs.map do |nr_attrs|
        name_role(nr_attrs.fetch(:name), nr_attrs.fetch(:role))
      end.compact.select { |mnr_attrs| @record.name_roles.exists?(**mnr_attrs) }

      return if mapped_name_roles.blank?

      mapped_name_roles.each { |mnr| @record.name_roles.destroy_by(**mnr) }
    end

    # @param host_collection_attrs [Array[Hash]]
    def add_host_collections!(host_collection_attrs = [])
      return if host_collection_attrs.blank?

      host_collections = host_collection_attrs.map do |host_col_attrs|
        find_or_create_host_collection(host_col_attrs[:name], @record.digital_object.institution)
      end.compact.reject { |hc| @record.desc_host_collections.exists?(host_collection: hc) }

      return if host_collections.blank?

      host_collections.each { |hc| @record.desc_host_collections.build(host_collection: hc) }
    end

    # @param host_collection_attrs [Array[Hash]]
    def remove_host_collections!(host_collection_attrs = [])
      return if host_collection_attrs.blank?

      host_collections = host_collection_attrs.map do |host_col_attrs|
        find_host_collection(host_col_attrs[:name], @record.digital_object.institution)
      end.compact.select { |hc| @record.desc_host_collections.exists?(host_collection: hc) }

      @record.desc_host_collections.destroy_by(host_collection: host_collections)
    end
  end
end
