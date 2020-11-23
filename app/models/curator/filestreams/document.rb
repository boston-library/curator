# frozen_string_literal: true

module Curator
  class Filestreams::Document < Filestreams::FileSet
    include Filestreams::Thumbnailable

    DEFAULT_REQUIRED_DERIVATIVES = %i(document_access characterization image_thumbnail_300).freeze

    belongs_to :file_set_of, inverse_of: :document_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :document_master
    has_one_attached :document_access

    def required_derivatives_complete?(required_derivatives = DEFAULT_REQUIRED_DERIVATIVES)
      super(required_derivatives)
    end

    def derivatives_payload
      derivatives_list = []

      with_current_host do
        if document_master.attached? && !document_access.attached?
          instructions = {}
          instructions[:source_url] = doucment_master_blob.service_url(expires_in: nil, disposition: :attachment)
          instructions[:types] = []
          instructions[:types] << :document_access
          instructions[:types] += [:characterization, :image_thumbnail_300].map do |attachment_type|
            attachment_type if !public_send(attachment_type).attached?
          end
          derivatives_list << instructions if instructions[:types].present?
        elsif document_access.attached?
          instructions = {}
          instructions[:source_url] = doucment_access_blob.service_url(expires_in: nil, disposition: :attachment)
          instructions[:types] = []
          instructions[:types] += [:characterization, :image_thumbnail_300].map do |attachment_type|
            attachment_type if !public_send(attachment_type).attached?
          end
          derivatives_list << instructions if instructions[:types].present?
        end
      end

      super.merge(derivatives: derivatives_list)
    end
  end
end
