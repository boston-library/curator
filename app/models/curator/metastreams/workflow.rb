# frozen_string_literal: true
module Curator
  class Metastreams::Workflow < ApplicationRecord
    belongs_to :workflowable, polymorphic: true, inverse_of: :workflow

    enum publishing_state: [:draft, :review, :published]
    enum processing_state: [:dervivatives, :complete]
  end
end
