# frozen_string_literal: true
module Curator
  module Metastreams
    module Workflowable
      extend ActiveSupport::Concern
      included do
        scope :with_workflow, -> { joins(:workflow).preload(:workflow) }
        has_one :workflow, as: :workflowable, inverse_of: :workflowable, class_name: Curator.metastreams.workflow_class_name, dependent: :destroy
      end
    end
  end
end
