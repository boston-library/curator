# frozen_string_literal: true
module CommonwealthCurator
  module Metastreams
    module Descriptable
      extend ActiveSupport::Concern
      included do
        scope :with_descriptive, -> { joins(:descriptive).preload(:descriptive) }
        has_one :descriptive, as: :descriptable, inverse_of: :descriptable, class_name: 'CommonwealthCurator::Metastreams::Descriptive', dependent: :destroy
      end
    end
  end
end
