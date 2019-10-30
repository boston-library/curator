# frozen_string_literal: true

module Curator
  class Filestreams::Ereader < Filestreams::FileSet
    include Filestreams::Characterizable
    belongs_to :file_set_of, inverse_of: :ereader_file_sets, class_name: Curator.digital_object_class_name

    acts_as_list scope: [:file_set_of, :file_set_type], top_of_list: 0

    has_one_attached :ebook_access
    has_one_attached :image_thumbnail_300
  end
end
