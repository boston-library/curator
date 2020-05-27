# frozen_string_literal: true

module Curator
  class Metastreams::DescriptiveUpdaterService < Services::Base
    include Services::UpdaterService
    include Metastreams::DescriptiveComplexAttrs
    include Mappings::TermMappable
    include Mappings::NameRolable

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
                                text_direction
                              ).freeze

    JSON_ATTRS = %i(cartographic
                  date
                  identifier
                  note
                  publication
                  related
                  subject_other
                  title
               ).freeze

    TERM_MAPPINGS = %w(genres resource_types languages).freeze

    def call
      with_transaction do
        simple_attributes_update(SIMPLE_ATTRIBUTES_LIST) do |simple_attr|
          @record.public_send("#{simple_attr}=", @json_attrs.fetch(simple_attr))
        end

        @record.resource_type_manuscript = @json_attrs.fetch(:resource_type_manuscript, @record.resource_type_manuscript)

        json_attr_update!

        physical_location_from_json = physical_location(@json_attrs)
        license_from_json = license(@json_attrs)

        @record.physical_location = physical_location_from_json if physical_location_from_json && @record.physical_location_id != physical_location_from_json.id

        @record.license = license_from_json if license_from_json  && @record.license_id != license_from_json.id

        term_mappings_update!
        subject_update!

        @record.save!
      end

      return @success, @result
    end

    protected

    def term_mappings_update!
      needs_removal = proc { |term_attr| term_attr.key?(:_destroy) && term_attr[:_destroy] == '1' }

      TERM_MAPPINGS.each do |map_type|

        mapped_terms = @json_attrs.fetch(map_type.to_s, [])

        next if mapped_terms.blank?

        terms_to_remove = mapped_terms.select(&needs_removal)
        terms_to_add = mapped_terms.select { |term_attrs| !needs_removal.call(term_attrs) }

        next if terms_to_add.blank? && terms_to_remove.blank?

        add_mapped_terms!(terms_to_add)

        remove_mapped_terms!(terms_to_remove)
      end
    end

    def subject_update!
      subject_terms = @json_attrs.dup.fetch(:subject, {}).slice(:topics, :names, :geos)

      return if subject_terms.blank?

      terms_to_add = subject_terms.reduce({}) do |ret, (k,v)|
        ret.merge(k => v.select { |term_attrs| !term_attrs.key?(:_destroy) } )
      end.with_indifferent_access

      terms_to_remove = subject_terms.reduce({}) do |ret, (k,v)|
        ret.merge(k => v.select { |term_attr| term_attrs.key?(:_destroy)  && term_attrs[:_destroy] == '1' })
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

    private

    def add_subject_terms!(subject_terms = [])
      return if subject_terms.blank?

      subject_terms.each do |subject_term|
        next if @record.desc_terms.exists?(mapped_term: subject_term)

        @record.desc_terms.build(mapped_term: subject_term)
      end
    end

    def remove_subject_terms!(subject_terms = [])
      return if subject_terms.blank?

      subject_terms.each do |subject_term|

        next if !@record.desc_terms.exists?(mapped_term: subject_term)

        @record.desc_terms.where(mapped_term: mapped_term).destroy_all
      end
    end

    def add_mapped_terms!(mapped_terms = [])
      return if mapped_terms.blank?

      mapped_terms.each do |map_attr|

        next if map_attrs.key?(:_destroy)

        mapped_term = term_for_mapping(map_attrs,
                                       nomenclature_class: Curator.controlled_terms.public_send("#{map_type.singularize}_class"))

        next if @record.desc_terms.exists?(mapped_term: mapped_term)

        @record.desc_terms.build(mapped_term: mapped_term)
      end
    end

    def remove_mapped_terms!(mapped_terms = [])
      return if mapped_terms.blank?

      mapped_terms.each do |map_attr|

        next if !map_attrs.key?(:_destroy)

        mapped_term = term_for_mapping(map_attrs.except(:_destroy),
                                       nomenclature_class: Curator.controlled_terms.public_send("#{map_type.singularize}_class"))

        next if !@record.desc_terms.exists?(mapped_term: mapped_term)

        @record.desc_terms.where(mapped_term: mapped_term).destroy_all
      end
    end
  end
end
