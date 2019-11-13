# frozen_string_literal: true

module Curator
  class Filestreams::Audio < Filestreams::FileSet
    include Filestreams::Characterizable

    belongs_to :file_set_of, inverse_of: :audio_file_sets, class_name: Curator.digital_object_class_name

    acts_as_list scope: [:file_set_of, :file_set_type], top_of_list: 0

    has_one_attached :audio_access
    has_one_attached :audio_master
    has_one_attached :document_access
    has_one_attached :document_master
    has_one_attached :text_plain
  end
end
