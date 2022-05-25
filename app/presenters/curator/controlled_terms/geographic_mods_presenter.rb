# frozen_string_literal: true

module Curator
  class ControlledTerms::GeographicModsPresenter
    # This classs acts as a wrapper for serializing <mods:subject><mods:geographic>, <mods:hierarchicalGeographic> and <mods:cartographic> elements/attributes
    class TgnHierGeo
      # This class is for serializing <mods:subject><mods:hierarchicalGeographic> elements
      attr_reader(*Curator::Parsers::Constants::TGN_HIER_GEO_ATTRS)
      # @param[optional] :continent [String]
      # @param[optional] :country [String]
      # @param[optional] :region [String]
      # @param[optional] :province [String]
      # @param[optional] :state [String]
      # @param[optional] :territory [String]
      # @param[optional] :county [String]
      # @param[optional] :island [String]
      # @param[optional] :city [String]
      # @param[optional] :city_section [String]
      # @param[optional] :area [String]
      # @param[optional] :extraterrestrial_area [String]
      # @return [Curator::ControlledTerms::GeographicModsPresenter::HierGeo] instance
      def initialize(**hier_geo_attrs)
        hier_geo_attrs.each do |k, v|
          instance_variable_set("@#{k}", v) if Curator::Parsers::Constants::TGN_HIER_GEO_ATTRS.include?(k.to_sym)
        end
      end

      # @return [Boolean] for checking if all attributes in element are blank?
      def blank?
        Curator::Parsers::Constants::TGN_HIER_GEO_ATTRS.all? { |attr| public_send(attr).blank? }
      end

      # @return Array[string] for checking if a value is present. Used to check if it should show a displayLabel attr in the subject
      def hier_values
        return [] if blank?

        Curator::Parsers::Constants::TGN_HIER_GEO_ATTRS.map { |attr| public_send(attr) }.compact
      end
    end

    attr_reader :geographic, :cartographic, :hierarchical_geographic

    delegate :id_from_auth, :authority_code, to: :geographic, allow_nil: true

    # @param geographic_subject [Curator::ControlledTerms::Geographic]
    # @return [Curator::ControlledTerms::GeographicModsPresenter] instance
    def initialize(geographic_subject)
      @geographic = geographic_subject
      @cartographic = create_cartographic
      @hierarchical_geographic = fetch_heir_geographic
    end

    def has_hier_geo?
      hierarchical_geographic.present?
    end

    def label
      return geographic.label if !has_hier_geo?

      # don't render as <mods:geographic> if the value is included in the hier_values
      return if hierarchical_geographic.hier_values.include?(geographic.label)

      geographic.label
    end

    def display_label
      return if geographic.area_type.blank? || !has_hier_geo?

      return if hierarchical_geographic.respond_to?(geographic.area_type.to_sym) && hierarchical_geographic.public_send(geographic.area_type.to_sym).present?

      geographic.area_type
    end

    protected

    # @return [String | nil] url for bpldc_auth_api to fetch tgn data
    def bpldc_url
      return if id_from_auth.blank? || authority_code != 'tgn'

      "#{authority_code}/#{id_from_auth}"
    end

    private

    #
    # @return [Curator::DescriptiveFieldSets::CartographicModsPresenter | nil ]
    def create_cartographic
      cartographic_attrs = %i(bounding_box coordinates area_type).inject({}) do |ret, attr|
        next ret if !geographic.respond_to?(attr) || geographic.public_send(attr).blank?

        ret[attr] = geographic.public_send(attr)
        ret
      end

      return if cartographic_attrs.blank?

      Curator::DescriptiveFieldSets::CartographicModsPresenter.new(**cartographic_attrs)
    end

    # Fetches hier data for tgns
    # @return [Curator::ControlledTerms::GeographicModsPresenter::TgnHierGeo | nil]
    def fetch_heir_geographic
      return if bpldc_url.blank?

      auth_data = Curator::ControlledTerms::AuthorityService.call(path: bpldc_url, path_prefix: '/geomash')

      return if auth_data.blank? || auth_data&.fetch(:hier_geo, {}).blank?

      hier_geo_attrs = auth_data[:hier_geo].dup

      if auth_data.dig(:non_hier_geo, :value).blank?
        hier_geo_attrs = Curator::Parsers::GeoParser.normalize_tgn_hgeo(hier_geo_attrs)
        return TgnHierGeo.new(**hier_geo_attrs)
      end

      other_geo_value = auth_data[:non_hier_geo][:value]
      other_geo_value << " (#{geographic.area_type})" if geographic.area_type.present?

      hier_geo_attrs[:other] = other_geo_value
      hier_geo_attrs = Curator::Parsers::GeoParser.normalize_tgn_hgeo(hier_geo_attrs)

      TgnHierGeo.new(**hier_geo_attrs)
    end
  end
end
