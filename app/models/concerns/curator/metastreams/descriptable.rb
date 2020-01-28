# frozen_string_literal: true

module Curator
  module Metastreams
    module Descriptable
      extend ActiveSupport::Concern
      included do
        scope :with_descriptive, -> { includes(:descriptive) }
        has_one :descriptive, -> { merge(for_serialization) }, as: :descriptable, inverse_of: :descriptable, class_name: 'Curator::Metastreams::Descriptive', dependent: :destroy
      end
    end
  end
end
