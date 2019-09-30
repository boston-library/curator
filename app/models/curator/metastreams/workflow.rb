# frozen_string_literal: true
module Curator
  class Metastreams::Workflow < ApplicationRecord
    belongs_to :workflowable, polymorphic: true, inverse_of: :workflow

    enum publishing_state: [:draft, :review, :published]
    enum processing_state: [:dervivatives, :complete]


    with_options presence: true do
      validates :ingest_origin
      validates :ingest_filepath
      validates :ingest_filename
      validates :ingest_datastream
    end

    # t.string :ingest_origin, null: false
    # t.string :ingest_filepath, null: false
    # t.string :ingest_filename, null: false
    # t.string :ingest_datastream, null: false
  end
end
