# frozen_string_literal: true

module Curator
  module Metastreams
    module Workflowable
      extend ActiveSupport::Concern
      included do
        scope :with_workflow, -> { includes(:workflow) }
        has_one :workflow, as: :workflowable, inverse_of: :workflowable, class_name: 'Curator::Metastreams::Workflow', dependent: :destroy
        validates :administrative, presence: true
        validates_associated :administrative, on: :create
      end
    end
  end
end
