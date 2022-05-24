# frozen_string_literal: true

module Curator
  module ControlledTerms
    module NameJson
      extend ActiveSupport::Concern

      included do
        include Curator::ControlledTerms::NomenclatureJson
        attributes :affiliation, :authority_code, :name_type
      end
    end
  end
end
