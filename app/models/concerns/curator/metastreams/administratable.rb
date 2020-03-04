# frozen_string_literal: true

module Curator
  module Metastreams
    module Administratable
      extend ActiveSupport::Concern
      included do
        scope :with_administrative, -> { joins(:administrative).includes(:administrative) }
        has_one :administrative, as: :administratable, inverse_of: :administratable, class_name: 'Curator::Metastreams::Administrative', dependent: :destroy

        validates :administrative, presence: true
        validates_associated :administrative, on: :create
      end
    end
  end
end
