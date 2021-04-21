# frozen_string_literal: true

module Curator
  class Filestreams::Video < Filestreams::FileSet
    include Filestreams::Thumbnailable

    DEFAULT_REQUIRED_DERIVATIVES = %i(video_access characterization).freeze

    belongs_to :file_set_of, inverse_of: :video_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :document_access, service: :derivatives
    has_one_attached :document_primary

    has_one_attached :text_plain

    has_one_attached :video_access, service: :derivatives
    has_one_attached :video_primary

    has_paper_trail

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      super(required_derivatives)
    end

    def avi_params
      return if !video_primary.attached?
    end
  end
end
