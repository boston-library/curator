# frozen_string_literal: true

module Curator
  module ControlledTerms
    module JsonResourceType
      extend ActiveSupport::Concern

      included do
        include Curator::ControlledTerms::JsonNomenclature
        attributes :authority_code
      end
    end
  end
end
