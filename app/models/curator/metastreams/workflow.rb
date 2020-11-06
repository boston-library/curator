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
    end

    aasm(:processing_state, column: :processing_state, enum: true) do
      state :initialized, initial: true
      state :derivatives
      state :complete
    end
  end
end
