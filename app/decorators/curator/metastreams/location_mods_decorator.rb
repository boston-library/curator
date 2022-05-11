# frozen_string_literal: true

module Curator
  class Metastreams::LocationModsDecorator < Decorators::BaseDecorator
    def digital_object
      return if !__getobj__.respond_to?(:digital_object)

      super
    end

    def physical_location
      return if !__getobj__.respond_to?(:physical_location)

      super
    end

    def physical_location_name
      return if physical_location.blank?

      physical_location.label
    end

    def physical_location_department
      return if !__getobj__.respond_to?(:physical_location_department)

      super
    end

    def physical_location_shelf_locator
      return if !__getobj__.respond_to?(:physical_location_shelf_locator)

      super
    end

    def identifiers
      return [] if !__getobj__.respond_to?(:identifier)

      __getobj__.identifier
    end

    def ark_identifier
      return if digital_object.blank?

      digital_object.ark_identifier
    end

    def ark_preview_identifier
      return if digital_object.blank?

      digital_object.ark_preview_identifier
    end

    def ark_iiif_manifest_identifier
      return if digital_object.blank?

      digital_object.ark_iiif_manifest_identifier
    end

    def ark_identifier_list
      return @ark_identifier_list if defined?(@ark_identifier_list)

      @ark_identifier_list = Array.wrap(ark_identifier) + Array.wrap(ark_preview_identifier) + Array.wrap(ark_iiif_manifest_identifier)
    end

    def uri_identifiers
      return @uri_identifiers if defined?(@uri_identifiers)

      return @uri_identifiers = [] if identifiers.blank?

      @uri_identifiers = identifiers.select { |ident| %w(iiif-manifest uri uri uri-preview).include?(ident.type) }
    end

    def has_uri_identifier?(ident_type)
      return false if uri_identifiers.blank?

      uri_identifiers.any? { |ident| ident.type == ident_type }
    end

    def has_ark_identifier?(ident_type)
      return false if ark_identifier_list.blank?

      ark_identifier_list.any? { |ident| ident.type == ident_type }
    end

    def holding_simple
      return if physical_location_department.blank? && physical_location_shelf_locator.blank?

      Curator::Metastreams::HoldingSimpleModsPresenter.new(sub_location: physical_location_department, shelf_locator: physical_location_shelf_locator)
    end

    def location_uri_list
      return @location_uri_list if defined?(@location_uri_list)

      return @location_uri_list = map_location_url_presenters
    end

    # NOTE: the #to_a method needs to include the uri elments spearate from the other based on how the mods is displayed
    # @return Array[Curator::Metastreams::LocationModsPresenter]
    def to_a
      ret_array = []
      ret_array << Curator::Metastreams::LocationModsPresenter.new(physical_location_name: physical_location_name, holding_simple: holding_simple) if physical_location_name.present? || holding_simple.present?
      ret_array << Curator::Metastreams::LocationModsPresenter.new(uri_list: location_uri_list) if location_uri_list.present?
      ret_array
    end

    # @return [Boolean] - Needed for mods serializer
    def blank?
      return true if __getobj__.blank?

      digital_object.blank? && physical_location.blank? && identifiers.blank? && holding_simple.blank?
    end

    private

    def map_location_url_presenters
      return [] if uri_identifiers.blank? && ark_identifier_list.blank?

      %w(uri uri-preview iiif-manifest).inject([]) do |ret, ident_type|
        ret << build_location_presenter(ident_type)
        ret
      end.compact
    end

    def build_location_presenter(ident_type)
      uri_finder = ->(id_type) { uri_identifiers.find { |url| url.type == id_type } }
      ark_uri_finder = ->(id_type) { ark_identifier_list.find { |url| url.type == id_type } }

      return if !has_ark_identifier?(ident_type) && !has_uri_identifier?(ident_type)

      ident = if has_uri_identifier?(ident_type)
                uri_finder.call(ident_type)
              elsif has_ark_identifier?(ident_type)
                ark_uri_finder.call(ident_type)
              end

      return if ident.blank?

      case ident_type
      when 'uri'
        Curator::DescriptiveFieldSets::LocationUrlModsPresenter.new(ident.label, usage: 'primary', access: 'object in context')
      when 'uri-preview'
        Curator::DescriptiveFieldSets::LocationUrlModsPresenter.new(ident.label, access: 'preview')
      when 'iiif-manifest'
        Curator::DescriptiveFieldSets::LocationUrlModsPresenter.new(ident.label, note: ident_type)
      end
    end
  end
end
