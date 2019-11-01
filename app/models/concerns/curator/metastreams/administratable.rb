# frozen_string_literal: true

module Curator
  module Metastreams
    module Administratable
      extend ActiveSupport::Concern
      included do
        scope :with_administrative, -> { includes(:administrative) }
        has_one :administrative, as: :administratable, inverse_of: :administratable, class_name: Curator.metastreams.administrative_class_name, dependent: :destroy
      end
    end
  end
end
