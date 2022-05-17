# frozen_string_literal: true

module Curator
  class Metastreams::RecordInfoModsDecorator < Decorators::BaseDecorator
    # DESCRIPTION: This class wraps and delegates a Curator::Metastreams::Descriptive to serialize and display sub elements for <mods:recordInfo>
    # RecordInfoModsDecorator#initialize
    ## @param obj [Curator::Metastreams::Descriptive]
    ## @return [Curator::Metastreams::RecordInfoModsDecorator]
    ## USAGE:
    ###  desc = Curator.metastreams.descriptive_class.for_serialization.find_by(..)
    ###  record_info = Curator::Metastreams:RecordInfoModsDecorator.new(desc)

    # @return [String] - this is used to serialize/display the <mods:recordInfo><mods:recordOrigin> sub element
    def record_origin
      return if __getobj__.blank?

      Metastreams::DEFAULT_MODS_RECORD_ORIGIN
    end

    # @return [String] - this is used for any <mods:recordInfo> sub elements that have an encoding attribute like <mods:recordInfo><mods:recordCreationDate encoding='this value'>
    def date_encoding
      return if __getobj__.blank?

      Curator::Parsers::Constants::DATE_ENCODING
    end

    # @return [String] - this is used to serialize/display the <mods:recordInfo><mods:recordContentSource> sub element
    def record_content_source
      return if record_hosting_status.blank?

      case record_hosting_status
      when 'hosted'
        'Boston Public Library'
      when 'harvested'
        record_institution_name
      end
    end

    def record_hosting_status
      return @record_hosting_status if defined?(@record_hosting_status)

      return @record_hosting_status = nil if digital_object.blank? || digital_object.administrative.blank?

      @record_hosting_status = digital_object.administrative.hosting_status
    end

    def record_institution_name
      return @record_institution_name if defined?(@record_institution_name)

      return @record_institution_name = nil if digital_object.blank? || !digital_object.respond_to?(:institution)

      @record_institution_name = digital_object.institution&.name
    end

    # @return [ISO8601-String] - this is used to serialize/display <mods:recordInfo><mods:recordCreationDate> sub element
    def record_creation_date
      return @record_creation_date if defined?(@record_creation_date)

      return @record_creation_date = nil if __getobj__.blank? || !__getobj__.respond_to?(:created_at)

      @record_creation_date = __getobj__.created_at&.iso8601
    end

    # @return [ISO8601-String] - this is used to serialize/display the <mods:recordInfo><mods:recordChangeDate> sub element
    def record_change_date
      return @record_change_date if defined?(@record_change_date)

      return @record_change_date = nil if __getobj__.blank? || !__getobj__.respond_to?(:updated_at)

      @record_change_date = __getobj__.updated_at&.iso8601
    end

    # @return [Curator::DigitalObject] parent
    def digital_object
      return super if __getobj__.respond_to?(:digital_object)
    end

    # @return [Curator::DescriptiveFieldSets::LanguageOfCatalogingModsPresenter] instance - This is used to serialize/display the <mods:recordInfo><mods:languageOfCataloging> sub elements
    def language_of_cataloging
      return @language_of_cataloging if defined?(@language_of_cataloging)

      return @language_of_cataloging = nil if __getobj__.blank?

      @language_of_cataloging = Curator::DescriptiveFieldSets::LanguageOfCatalogingModsPresenter.new
    end

    # @return [String] - This is used to serialize/display the <mods:recordInfo><mods:descriptionStandard> sub element
    def description_standard
      return @description_standard if defined?(@description_standard)

      return @description_standard = nil if digital_object.blank? || digital_object.administrative.blank?

      @description_standard = digital_object.administrative.description_standard
    end

    # @return [String] - This is used to get the value for the authority attribute in <mods:recordInfo><mods:descriptionStandard authority='this value'>
    def description_standard_authority
      return if __getobj__.blank?

      Metastreams::DEFAULT_MODS_DESC_STANDARD_AUTH
    end

    # @return [Boolean] - Needed for mods serializer
    def blank?
      return true if __getobj__.blank?

      digital_object.blank? && record_creation_date.blank? && record_change_date.blank?
    end
  end
end
