# frozen_string_literal: true

module Curator
  module ControlledTerms
    module JsonGenre
      extend ActiveSupport::Concern

      included do
        include Curator::ControlledTerms::JsonNomenclature
        attributes :basic, :authority_code
      end
    end
  end
end
