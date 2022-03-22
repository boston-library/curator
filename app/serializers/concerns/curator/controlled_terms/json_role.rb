# frozen_string_literal: true

module Curator
  module ControlledTerms
    module JsonRole
      extend ActiveSupport::Concern

      included do
        attributes :authority_code
      end
    end
  end
end
