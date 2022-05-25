# frozen_string_literal: true

module Curator
  module ControlledTerms
    module AccessConditionJson
      extend ActiveSupport::Concern

      included do
        attributes :label, :uri
      end
    end
  end
end
