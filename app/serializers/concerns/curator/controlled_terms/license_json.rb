# frozen_string_literal: true

module Curator
  module ControlledTerms
    module LicenseJson
      extend ActiveSupport::Concern

      included do
        include ControlledTerms::AccessConditionJson
      end
    end
  end
end
