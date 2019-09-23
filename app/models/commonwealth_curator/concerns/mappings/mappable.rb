# frozen_string_literal: true
module CommonwealthCurator
  module Mappings
    module Mappable
      extend ActiveSupport::Concern
      included do
        has_many :descriptive_term_mappings, as: :mappable, inverse_of: :mappable, class_name: 'CommonwealthCurator::Metastreams::DescriptiveTermMapping'
      end
    end
  end
end
