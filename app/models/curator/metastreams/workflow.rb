# frozen_string_literal: true

module Curator
  class Metastreams::Workflow < ApplicationRecord
    belongs_to :workflowable, polymorphic: true, inverse_of: :workflow

    enum publishing_state: { draft: 0, review: 1, published: 2 }.freeze
    enum processing_state: { dervivatives: 0, complete: 1 }.freeze

    validates :ingest_origin, presence: true
    validates :workflowable_id, uniqueness: { scope: :workflowable_type }, on: :create
    validates :workflowable_type, inclusion: { in: Metastreams.valid_base_types + Metastreams.valid_filestream_types }, on: :create

    def workflowable=(workflowable)
      super
      self.workflowable_type = workflowable.class.to_s
    end
  end
end
