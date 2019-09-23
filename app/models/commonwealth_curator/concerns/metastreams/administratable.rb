# frozen_string_literal: true
module CommonwealthCurator
  module Metastreams
    module Administratable
      extend ActiveSupport::Concern

      included do
        has_one :administrative, as: :administratable, inverse_of: :administratable, class_name: 'CommonwealthCurator::Metastreams::Administrative'
      end
    end
  end
end
