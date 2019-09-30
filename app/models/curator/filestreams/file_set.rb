# frozen_string_literal: true
module Curator
  class Filestreams::FileSet < ApplicationRecord
    include Curator::Metastreams::Workflowable
    include Curator::Metastreams::Administratable
    include AttrJson::Record
    include AttrJson::Record::Dirty
    include AttrJson::Record::QueryScopes

    enum file_set_type: %w(image ereader document audio video).freeze

    belongs_to :file_set_of, polymorphic: true, inverse_of: :file_sets
    acts_as_list scope: :file_set_of

    has_many :exemplary_image_mappings, -> { joins(:exemplary).preload(:exemplary) }, inverse_of: :file_set, class_name: Curator.mappings.exemplary_image_class.to_s

    has_many :exemplary_image_collections, through: :exemplary_image_mappings, source: :exemplary, source_type: Curator.collection_class.to_s
    has_many :exemplary_image_digital_objects, through: :exemplary_image_mappings, source: :exemplary, source_type: Curator.digital_object_class.to_s

    def exemplary_image_of
    end

    def exemplary_image_mappings
      %w(image video document).include?(self.file_type) ? super : Curator.mappings.exemplary_image_class.none
    end #May need to include other file set types Also need to make read only if it does not fall within this type.

    attr_json_config(default_container_attribute: :checksum_data)

    attr_json :ingest_datastream_md5, :string
    attr_json :ingest_datastream_sha1, :string

  end
end
