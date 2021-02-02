# frozen_string_literal: true

module Curator
  class Filestreams::Video < Filestreams::FileSet
    include Filestreams::Thumbnailable

    DEFAULT_REQUIRED_DERIVATIVES = %i(video_access characterization).freeze

    belongs_to :file_set_of, inverse_of: :video_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :document_access
    has_one_attached :document_master

    has_one_attached :text_plain

    has_one_attached :video_access
    has_one_attached :video_master

    has_paper_trail

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      super(required_derivatives)
    end

    def derivatives_payload
      derivatives_list = []

      with_current_host do
        if video_master.attached? && !video_access.attached?
          instructions = {}
          instructions[:source_url] = video_master_blob.service_url(expires_in: nil, disposition: :attachment)
          instructions[:types] = []
          instructions[:types] << :video_access
          instructions[:types] += [:characterization, :image_thumbnail_300].map do |attachment_type|
            attachment_type if !public_send(attachment_type).attached?
          end
          derivatives_list << instructions if instructions[:types].present?
        elsif video_access.attached?
          instructions = {}
          instructions[:source_url] = video_access_blob.service_url(expires_in: nil, disposition: :attachment)
          instructions[:types] = []
          instructions[:types] += [:characterization, :image_thumbnail_300].map do |attachment_type|
            attachment_type if !public_send(attachment_type).attached?
          end
          derivatives_list << instructions if instructions[:types].present?
        end

        if document_master.attached? && !document_access.attached?
          instructions = {}
          instructions[:source_url] = document_master_blob.service_url(expires_in: nil, disposition: :attachment)
          instructions[:types] = []
          instructions[:types] << :document_access
          derivatives_list << instructions if instructions[:types].present?
        end
      end

      super.merge(derivatives: derivatives_list)
    end
  end
end
