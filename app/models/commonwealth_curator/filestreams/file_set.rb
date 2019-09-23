# frozen_string_literal: true
module CommonwealthCurator
  class Filestreams::FileSet < ApplicationRecord
    enum file_set_type: %w(image transcription marc ereader document audio video)

    belongs_to :file_set_of, polymorphic: true, inverse_of: :file_sets

    has_many :exemplary_image_mappings, inverse_of: :file_set, class_name: 'CommonwealthCurator::Mappings'

  end
end
