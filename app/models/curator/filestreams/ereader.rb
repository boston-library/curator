# frozen_string_literal: true

module Curator
  class Filestreams::Ereader < Filestreams::FileSet
    belongs_to :file_set_of, inverse_of: :ereader_file_sets, class_name: 'Curator::DigitalObject'

    has_many_attached :ebook_access

    has_one_attached :image_thumbnail_300
  end
end
