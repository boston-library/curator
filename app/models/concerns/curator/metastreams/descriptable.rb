# frozen_string_literal: true

module Curator
  module Metastreams
    module Descriptable
      extend ActiveSupport::Concern
      included do
        scope :with_descriptive, -> { joins(:descriptive).includes(:descriptive).merge(Curator.metastreams.descriptive_class.with_mappings) }
        has_one :descriptive, -> { merge(with_desc_terms) }, as: :descriptable, inverse_of: :descriptable, class_name: 'Curator::Metastreams::Descriptive', dependent: :destroy

        validates :descriptive, presence: true
        validates_associated :descriptive, on: :create
      end
    end
  end
end
