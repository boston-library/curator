# frozen_string_literal: true

module Curator
  module Metastreams
    module Administratable
      extend ActiveSupport::Concern
      included do
        include InstanceMethods

        scope :with_administrative, -> { includes(:administrative) }
        has_one :administrative, as: :administratable, inverse_of: :administratable,
                class_name: 'Curator::Metastreams::Administrative', dependent: :destroy, autosave: true

        validates :administrative, presence: true
        validates_associated :administrative, on: :create

        delegate :oai_object?, to: :administrative, allow_nil: true
      end

      module InstanceMethods
        def is_hosted?
          return false if administrative.blank?

          administrative.hosting_status == 'hosted'
        end

        def is_harvested?
          return false if administrative.blank?

          administrative.hosting_status == 'harvested'
        end
      end
    end
  end
end
