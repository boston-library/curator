# frozen_string_literal: true

module Curator
  module ControlledTerms
    module GeographicJson
      extend ActiveSupport::Concern

      included do
        include Curator::ControlledTerms::NomenclatureJson
        attributes :area_type, :coordinates, :bounding_box, :authority_code
      end
    end
  end
end
