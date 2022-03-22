# frozen_string_literal: true

module Curator
  module ControlledTerms
    module JsonRightsStatement
      extend ActiveSupport::Concern

      included do
        attributes :uri
      end
    end
  end
end
