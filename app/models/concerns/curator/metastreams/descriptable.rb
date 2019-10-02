# frozen_string_literal: true
module Curator
  module Metastreams
    module Descriptable
      extend ActiveSupport::Concern
      included do
        scope :with_descriptive, -> { joins(:descriptive).preload(:descriptive) }
        has_one :descriptive, as: :descriptable, inverse_of: :descriptable, class_name: Curator.metastreams.descriptive_class_name, dependent: :destroy
      end
    end
  end
end
