# frozen_string_literal: true

module Curator
  class ControlledTerms::GeographicModsPresenter
    attr_reader :geographic, :cartographic, :hierachical_geographic

    delegate :label, :authority_code, :authority_base_url, :value_uri, :id_from_auth, to: :geographic, allow_nil: true

    def initialize(geographic)
      @geographic = geographic
      @cartographic = Curator::DescriptiveFieldSets::CartographicModsPresenter.new(coordinates: geographic.coordinates) if geographic.coordinates.present?
    end

    def bpldc_url
      return if id_from_auth.blank? || authority_code != 'tgn'

      "#{authority_code}/#{id_from_auth}"
    end

    private

    def fetch_heir_geograhic
      return if bpldc_url.blank?

      auth_data = Curator::ControlledTerms::AuthorityService.call(path: bpldc_url, path_prefix: '/geomash')
    end
  end
end
