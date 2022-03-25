# frozen_string_literal: true

module Curator
  module ControlledTerms
    module JsonRightsStatement
      extend ActiveSupport::Concern

      included do
        include Curator::ControlledTerms::JsonNomenclature
        attributes :uri
      end
    end
  end
end
