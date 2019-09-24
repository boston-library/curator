# frozen_string_literal: true
module CommonwealthCurator
  class Filestreams::FileSet < ApplicationRecord
    include CommonwealthCurator::Metastreams::Workflowable
    include CommonwealthCurator::Metastreams::Administratable
    include AttrJson::Record
    include AttrJson::Record::Dirty
    include AttrJson::Record::QueryScopes

    enum file_set_type: %w(image transcription marc ereader document audio video)

    belongs_to :file_set_of, polymorphic: true, inverse_of: :file_sets
    acts_as_list scope: :file_set_of

    has_many :exemplary_image_mappings, -> { joins(:exemplary_image_of).preload(:exemplary_image_of) }, inverse_of: :file_set, class_name: 'CommonwealthCurator::Mappings::ExemplaryImage'

    has_many :exemplary_image_collections, through: :exemplary_image_mappings, source: :exemplary_image_of, source_type: 'CommonwealthCurator::Collection'
    has_many :exemplary_image_digital_objects, through: :exemplary_image_mappings, source: :exemplary_image_of, source_type: 'CommonwealthCurator::DigitalObject'


    def exemplary_image_mappings
      self.file_set_type == 'image' ? super : CommonwealthCurator::Mappings::ExemplaryImage.none
    end #May need to include other file set types

    attr_json_config(default_container_attribute: :checksum_data)

    attr_json :ingest_datastream_md5, :string
    attr_json :ingest_datastream_sha1, :string
  end
end
