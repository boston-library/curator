# frozen_string_literal: true
module CommonwealthCurator
  module Metastreams
    module Workflowable
      extend ActiveSupport::Concern
      included do
        default_scope { joins(:workflow).preload(:workflow) }
        has_one :workflow, as: :workflowable, inverse_of: :workflowable, class_name: 'CommonwealthCurator::Metastreams::Workflow', dependent: :destroy
      end
    end
  end
end
