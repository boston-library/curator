# frozen_string_literal: true
module CommonwealthCurator
  module Metastreams
    module Workflowable
      extend ActiveSupport::Concern
      included do
        has_one :workflow, as: :workflowable, inverse_of: :workflowable, class_name: 'CommonwealthCurator::Metastreams::Workflow'
      end
    end
  end
end
