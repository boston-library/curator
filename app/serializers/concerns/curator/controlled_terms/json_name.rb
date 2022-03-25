# frozen_string_literal: true

module Curator
  module ControlledTerms
    module JsonName
      extend ActiveSupport::Concern

      included do
        include Curator::ControlledTerms::JsonNomenclature
        attributes :affiliation, :authority_code, :name_type
      end
    end
  end
end
