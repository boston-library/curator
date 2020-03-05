# frozen_string_literal: true

module Curator
  module Metastreams
    module Descriptable
      extend ActiveSupport::Concern
      included do
        scope :with_descriptive, -> { joins(:descriptive).includes(:descriptive) }
        has_one :descriptive, as: :descriptable, inverse_of: :descriptable, class_name: 'Curator::Metastreams::Descriptive', dependent: :destroy

        validates :descriptive, presence: true
        validates_associated :descriptive, on: :create
      end
    end
  end
end
