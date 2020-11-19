# frozen_string_literal: true

module Curator
  class Filestreams::Text < Filestreams::FileSet
    belongs_to :file_set_of, inverse_of: :text_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :text_plain
    has_one_attached :text_coordinates_master

    def derivatives_complete?
      text_plain.attached? && characterization.attached?
    end

    def derivatives_payload
      derivatives_list = []
      with_current_host do
        if text_plain.attached?
          instructions = {}
          instuctions[:source_url] = text_plain_blob.service_url(expires_in: nil, disposition: :attachment)
          instructions[:types] = []
          instructions[:types] << :characterization if !characterization.attached?
        end
      end
      super.merge(derivatives: derivatives_list)
    end
  end
end
