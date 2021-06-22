# frozen_string_literal: true

module Curator
  module Metastreams
    module Descriptable
      extend ActiveSupport::Concern
      included do
        scope :with_descriptive, -> { includes(:descriptive) }

        has_one :descriptive, -> { merge(with_physical_location).merge(with_license).merge(with_desc_terms).merge(with_rights_statement) },
                inverse_of: :digital_object, class_name: 'Curator::Metastreams::Descriptive', dependent: :destroy, autosave: true

        validates :descriptive, presence: true
        validates_associated :descriptive, on: :create
      end
    end
  end
end
