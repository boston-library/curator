# frozen_string_literal: true

module Curator
  class Filestreams::Document < Filestreams::FileSet
    include Filestreams::Thumbnailable

    belongs_to :file_set_of, inverse_of: :document_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :document_master
    has_one_attached :document_access

    def derivatives_complete?
      #All derivatives for this fileset type are attached?
      true
    end
  end
end
