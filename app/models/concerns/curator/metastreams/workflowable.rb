# frozen_string_literal: true

module Curator
  module Metastreams
    module Workflowable
      extend ActiveSupport::Concern
      included do
        scope :with_workflow, -> { includes(:workflow) }
        has_one :workflow, as: :workflowable, inverse_of: :workflowable,
                class_name: 'Curator::Metastreams::Workflow', dependent: :destroy, autosave: true

        validates :workflow, presence: true
        validates_associated :workflow, on: :create

        after_create_commit :begin_workflow

        after_update_commit :complete_workflow

        private

        def begin_workflow
          workflow.publish! if workflow.may_publish?
          workflow.process_derivatives! if workflow.may_process_derivatives?
        end

        def complete_workflow
          workflow.mark_complete! if workflow.may_mark_complete?
        end
      end
    end
  end
end
