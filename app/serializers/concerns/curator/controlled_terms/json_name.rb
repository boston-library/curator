# frozen_string_literal: true

module Curator
  module ControlledTerms
    module JsonName
      extend ActiveSupport::Concern

      included do
        attributes :affiliation, :authority_code, :name_type
      end
    end
  end
end
