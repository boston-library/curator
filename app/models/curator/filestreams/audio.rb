# frozen_string_literal: true

module Curator
  class Filestreams::Audio < Filestreams::FileSet
    belongs_to :file_set_of, inverse_of: :audio_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :audio_access
    has_one_attached :audio_master
    has_one_attached :document_access
    has_one_attached :document_master
    has_one_attached :text_plain

    def derivatives_complete?
      #All derivatives for this fileset type are attached?
      true
    end
  end
end
