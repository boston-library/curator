# frozen_string_literal: true

module Curator
  class Filestreams::Ereader < Filestreams::FileSet
    include Filestreams::Thumbnailable

    belongs_to :file_set_of, inverse_of: :ereader_file_sets, class_name: 'Curator::DigitalObject'

    has_many_attached :ebook_access

    def derivatives_complete?
      #All derivatives for this fileset type are attached?
      true
    end
  end
end
