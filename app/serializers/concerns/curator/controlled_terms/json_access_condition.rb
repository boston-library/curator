# frozen_string_literal: true

module Curator
  module ControlledTerms
    module JsonAccessCondition
      extend ActiveSupport::Concern

      included do
        attributes :label, :uri
      end
    end
  end
end
