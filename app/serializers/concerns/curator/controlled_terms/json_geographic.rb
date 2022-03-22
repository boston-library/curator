# frozen_string_literal: true

module Curator
  module ControlledTerms
    module JsonGeographic
      extend ActiveSupport::Concern

      included do
        attributes :area_type, :coordinates, :bounding_box, :authority_code
      end
    end
  end
end
