# frozen_string_literal: true

module Curator
  class Metastreams::Workflow < ApplicationRecord
    include AASM

    belongs_to :workflowable, polymorphic: true, inverse_of: :workflow, touch: true

    enum publishing_state: { draft: 'draft',
                             review: 'review',
                             published: 'published'
                           }.freeze

    enum processing_state: { initialized: 'initialized',
                             derivatives: 'derivatives',
                             complete: 'complete'
                           }.freeze

    validates :ingest_origin, presence: true

    validates :publishing_state, inclusion: { in: publishing_states.keys }
    validates :processing_state, inclusion: { in: processing_states.keys }

    validates :workflowable_id, uniqueness: { scope: :workflowable_type }, on: :create

    validates :workflowable_type, inclusion: { in: Metastreams.valid_base_types + Metastreams.valid_filestream_types }, on: :create

    aasm(:publishing_state, column: :publishing_state, enum: true) do
      state :draft, initial: true
      state :review
      state :published

      event :start_review, guard: :should_review? do
        transitions from: :draft, to: :review
      end

      event :publish do
        transitions from: :draft, to: :published, guard: :is_publishable?
      end
    end

    aasm(:processing_state, column: :processing_state, enum: true) do
      state :initialized, initial: true
      state :derivatives
      state :complete

      event :process_derivatives, binding_event: :publish do
        transitions from: :initialized, to: :derivatives, guard: :is_processable?
        transitions from: :initialized, to: :initialized
      end

      event :mark_complete, guard: :can_complete? do
        transitions from: :derivatives, to: :complete
      end
    end

    protected

    # GUARD CLAUSES
    def should_review?
      false
    end

    def can_complete?
      case workflowable_type
      when 'Curator::DigitalObject'
        workflowable.all_file_sets_complete?
      when 'Curator::Filestreams::FileSet'
        workflowable.derivatives_complete?
      else
        false
      end
    end

    def is_processable?
      case workflowable_type
      when 'Curator::DigitalObject', 'Curator::Filestreams::FileSet'
        true
      else
        false
      end
    end

    def is_publishable?
      case workflowable_type
      when 'Curator::Institution', 'Curator::Collection', 'Curator::DigitalObject'
        true
      else
        false
      end
    end
  end
end
