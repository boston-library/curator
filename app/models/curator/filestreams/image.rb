# frozen_string_literal: true

module Curator
  class Filestreams::Image < Filestreams::FileSet
    include Filestreams::Thumbnailable
    belongs_to :file_set_of, inverse_of: :image_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :document_access
    has_one_attached :image_master
    has_one_attached :image_negative_master
    has_one_attached :image_georectified_master
    has_one_attached :image_access_800
    has_one_attached :image_service

    has_one_attached :text_coordinates_master
    has_one_attached :text_coordinates_access

    has_one_attached :text_plain

    def derivatives_complete?
      image_service.attached? && characterization.attached? && image_thumbnail_300.attached?
    end

    def derivatives_payload
      derivatives_list = []

      with_current_host do
        if image_master.attached? && !image_service.attached?
          instructions = {}
          instructions[:source_url] = image_master_blob.service_url(expires_in: nil, disposition: :attachment)
          instructions[:types] = []
          instructions[:types] << :image_service
          instructions[:types] += [:characterization, :image_thumbnail_300].map do |attachment_type|
            attachment_type if !public_send(attachment_type).attached?
          end
          derivatives_list << instructions if instructions[:types].present?
        elsif image_service.attached?
          instructions = {}
          instructions[:source_url] = image_service_blob.service_url(expires_in: nil, disposition: :attachment)
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
