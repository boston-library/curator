# frozen_string_literal: true

module Curator
  module ControlledTerms
    module GenreJson
      extend ActiveSupport::Concern

      included do
        include Curator::ControlledTerms::NomenclatureJson
        attributes :basic, :authority_code
      end
    end
  end
end
