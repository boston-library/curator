# frozen_string_literal: true
module CommonwealthCurator
  module Mappings
    module ExemplaryImagable
      extend ActiveSupport::Concern
      included do
        has_many :exemplary_image_mappings, as: :exemplary, inverse_of: :exemplary, class_name: 'CommonwealthCurator::Mappings::ExemplaryImage'
      end
    end
  end
end
