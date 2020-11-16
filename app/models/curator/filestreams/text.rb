# frozen_string_literal: true

module Curator
  class Filestreams::Text < Filestreams::FileSet
    belongs_to :file_set_of, inverse_of: :text_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :text_plain
    has_one_attached :text_coordinates_master

    def derivatives_complete?
      #All derivatives for this fileset type are attached?
      true
    end
  end
end
