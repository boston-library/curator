# frozen_string_literal: true

module Curator
  class Metastreams::RecordInfoModsDecorator < Decorators::BaseDecorator
    DEFAULT_RECORD_ORIGIN='human prepared'

    def record_origin
      return if __getobj__.blank?

      DEFAULT_RECORD_ORIGIN
    end

    def date_encoding
      return if __getobj__.blank?

      Curator::DescriptiveFieldSets::DateModsDecorator::DATE_ENCODING
    end

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

    def record_creation_date
      return @record_creation_date if defined?(@record_creation_date)

      return @record_creation_date = nil if __getobj__.blank? || !__getobj__.respond_to?(:created_at)

      @record_creation_date = __getobj__.created_at&.iso8601
    end

    def record_change_date
      return @record_change_date if defined?(@record_change_date)

      return @record_change_date = nil if __getobj__.blank? || !__getobj__.respond_to?(:updated_at)

      @record_change_date = __getobj__.updated_at&.iso8601
    end

    def digital_object
      return @digital_object if defined?(@digital_object)

      return @digital_object = nil if __getobj__.blank? || !__getobj__.respond_to?(:digital_object)

      @digital_object = __getobj__.digital_object
    end

    def language_of_cataloging
      return @language_of_cataloging if defined?(@language_of_cataloging)

      return @language_of_cataloging = nil if __getobj__.blank?

      @language_of_cataloging = Curator::DescriptiveFieldSets::LanguageOfCatalogingModsPresenter.new
    end

    def description_standard
      return @description_standard if defined?(@description_standard)

      return @description_standard = nil if digital_object.blank? || digital_object.administrative.blank?

      @description_standard = digital_object.administrative.description_standard
    end

    def blank?
      return true if __getobj__.blank?

      digital_object.blank? && record_creation_date.blank? && record_change_date.blank?
    end
  end
end
