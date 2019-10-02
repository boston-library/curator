# frozen_string_literal: true
module Curator
  class Filestreams::Text < Filestreams::FileSet
    belongs_to :file_set_of, inverse_of: :text_file_sets, class_name: Curator.digital_object_class_name

    acts_as_list scope: [:file_set_of, :file_set_type]

    has_one_attached :text_plain
    has_one_attached :text_coordinates_master
  end
end
