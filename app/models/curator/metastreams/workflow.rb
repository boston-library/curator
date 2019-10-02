# frozen_string_literal: true
module Curator
  class Metastreams::Workflow < ApplicationRecord
    include AttrJson::Record
    include AttrJson::Record::QueryScopes
    include AttrJson::Record::Dirty
    include AttrJson::NestedAttributes

    belongs_to :workflowable, polymorphic: true, inverse_of: :workflow

    enum publishing_state: [:draft, :review, :published]
    enum processing_state: [:dervivatives, :complete]


    with_options presence: true do
      validates :ingest_origin
      validates :ingest_filepath
      validates :ingest_filename
      validates :ingest_datastream
    end
    attr_json_config(default_container_attribute: :ingest_datastream_checksums)

    attr_json :ingest_datastream_md5, :string
    attr_json :ingest_datastream_sha1, :string
  end
end
