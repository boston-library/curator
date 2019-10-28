# frozen_string_literal: true
module Curator
  module Mappings
    module ExemplaryImageable
      extend ActiveSupport::Concern
      included do
        has_many :exemplary_image_mappings, as: :exemplary, inverse_of: :exemplary, class_name: Curator.mappings.exemplary_image_class_name
      end
    end
  end
end
