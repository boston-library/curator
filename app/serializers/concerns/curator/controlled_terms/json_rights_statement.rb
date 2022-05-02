# frozen_string_literal: true

module Curator
  module ControlledTerms
    module JsonRightsStatement
      extend ActiveSupport::Concern

      included do
        include ControlledTerms::JsonAccessCondition
      end
    end
  end
end
