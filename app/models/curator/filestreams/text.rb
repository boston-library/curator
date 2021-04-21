# frozen_string_literal: true

module Curator
  class Filestreams::Text < Filestreams::FileSet
    DEFAULT_REQUIRED_DERIVATIVES = %i(text_plain characterization).freeze

    belongs_to :file_set_of, inverse_of: :text_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :text_plain, service: :derivatives
    has_one_attached :text_coordinates_primary

    has_paper_trail

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      super(required_derivatives)
    end

    def derivatives_payload
      derivatives_list = []
      with_current_host do
        if text_plain.attached?
          instructions = {}
          instructions[:source_url] = text_plain_blob.service_url(expires_in: nil, disposition: :attachment)
          instructions[:types] = []
          instructions[:types] << :characterization if !characterization.attached?
        end
      end
      super.merge(derivatives: derivatives_list)
    end
  end
end
