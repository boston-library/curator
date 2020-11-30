# frozen_string_literal: true

module Curator
  module Metastreams
    module Workflowable
      extend ActiveSupport::Concern
      included do
        scope :with_workflow, -> { joins(:workflow).preload(:workflow) }
        has_one :workflow, as: :workflowable, inverse_of: :workflowable,
                class_name: 'Curator::Metastreams::Workflow', dependent: :destroy, autosave: true

        validates :workflow, presence: true
        validates_associated :workflow, on: :create

        after_create_commit :set_workflow_publish

        after_update_commit :set_workflow_complete

        private

        def set_workflow_publish
          workflow.publish! if workflow.may_publish?
        end

        def set_workflow_complete
          workflow.mark_complete! if workflow.may_mark_complete?
        end
      end
    end
  end
end
