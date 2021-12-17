# frozen_string_literal: true

module Curator
  class Metastreams::Workflow < ApplicationRecord
    include AASM

    PUBLISHABLE_CLASSES = ['Curator::Institution', 'Curator::Collection', 'Curator::DigitalObject'].freeze

    PROCESSABLE_CLASSES = ['Curator::DigitalObject', 'Curator::Filestreams::FileSet'].freeze

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

    validates :publishing_state, inclusion: { in: publishing_states.keys }, allow_nil: true, if: :is_publishable?
    validates :processing_state, inclusion: { in: processing_states.keys }, allow_nil: true, if: :is_processable?

    validates :workflowable_id, uniqueness: { scope: :workflowable_type }, on: :create

    validates :workflowable_type, inclusion: { in: Metastreams.valid_base_types + Metastreams.valid_filestream_types }, on: :create

    aasm(:publishing_state, column: :publishing_state, enum: true) do
      state :not_set # returns nil value
      state :draft
      state :review
      state :published
      initial_state proc { |w| w.is_publishable? ? :draft : :not_set }

      event :start_review, guard: :should_review? do
        transitions from: :draft, to: :review
      end

      event :publish do
        transitions from: :draft, to: :published, guard: :is_publishable?
      end
    end

    aasm(:processing_state, column: :processing_state, enum: true) do
      state :not_set # returns nil value
      state :initialized
      state :derivatives
      state :complete
      initial_state proc { |w| w.is_processable? ? :initialized : :not_set }

      event :process_derivatives, guard: :is_processable?, after_commit: :generate_derivatives do
        transitions from: :initialized, to: :derivatives
      end

      event :mark_complete, guards: [:is_processable?, :can_complete?] do
        transitions from: :derivatives, to: :complete
      end

      event :regenerate_derivatives, guards: [:is_processable?, :should_regenerate_derivatives?], after_commit: :regenerate_derivatives do
        transitions from: :complete, to: :derivatives
      end
    end

    has_paper_trail if: proc { |w| w.is_processable? }

    ## START GUARD CLAUSES
    def is_processable?
      PROCESSABLE_CLASSES.include?(workflowable_type)
    end

    def is_publishable?
      PUBLISHABLE_CLASSES.include?(workflowable_type)
    end

    protected

    def should_review?
      false
    end

    def should_regenerate_derivatives?
      return false if workflowable_type != 'Curator::Filestreams::FileSet'

      workflowable.respond_to?(:derivative_source_changed?) && workflowable.derivative_source_changed?
    end

    def can_complete?
      case workflowable_type
      when 'Curator::DigitalObject'
        workflowable.all_file_sets_complete?
      when 'Curator::Filestreams::FileSet'
        workflowable.required_derivatives_complete?
      else
        false
      end
    end
    ## END GUARD CLAUSES

    private

    def generate_derivatives
      return if workflowable_type != 'Curator::Filestreams::FileSet'

      Curator::Filestreams::DerivativesJob.perform_later(workflowable_type, workflowable_id)
    end

    alias regenerate_derivatives generate_derivatives
  end
end
