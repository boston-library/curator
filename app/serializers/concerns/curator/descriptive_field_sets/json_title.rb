# frozen_string_literal: true

module Curator
  module DescriptiveFieldSets
    module JsonTitle
      extend ActiveSupport::Concern

      included do
        attributes :label, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :authority_code, :id_from_auth, :part_name, :part_number
      end
    end
  end
end
