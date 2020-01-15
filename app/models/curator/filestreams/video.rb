# frozen_string_literal: true

module Curator
  class Filestreams::Video < Filestreams::FileSet
    include Curator::Mappings::Exemplary::FileSetImagable
    belongs_to :file_set_of, inverse_of: :video_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :document_access
    has_one_attached :document_master

    has_one_attached :image_thumbnail_300

    has_one_attached :text_plain

    has_one_attached :video_access
    has_one_attached :video_master
  end
end
