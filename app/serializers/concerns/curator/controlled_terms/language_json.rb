# frozen_string_literal: true

module Curator
  module ControlledTerms
    module LanguageJson
      extend ActiveSupport::Concern

      included do
        include Curator::ControlledTerms::NomenclatureJson
        attributes :authority_code
      end
    end
  end
end
