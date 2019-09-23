# frozen_string_literal: true
module CommonwealthCurator
  module Metastreams
    module Descriptable
      extend ActiveSupport::Concern
      included do
        has_one :descriptive, as: :descriptable, inverse_of: :descriptable, class_name: 'CommonwealthCurator::Metastreams::Descriptive'
      end
    end
  end
end
