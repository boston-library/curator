# frozen_string_literal: true

module Curator
  class Filestreams::Audio < Filestreams::FileSet
    belongs_to :file_set_of, inverse_of: :audio_file_sets, class_name: 'Curator::DigitalObject'

    has_one_attached :audio_access
    has_one_attached :audio_master
    has_one_attached :document_access
    has_one_attached :document_master
    has_one_attached :text_plain

    def derivatives_complete?
      audio_access.attached? && characterization.attached?
    end

    def derivatives_payload
      derivatives_list = []
      with_current_host do
        if audio_master.attached? && !audio_access.attached?
          instructions = {}
          instuctions[:source_url] = audio_master_blob.service_url(expires_in: nil, disposition: :attachment)
          instructions[:types] = []
          instructions[:types] << :audio_access
          instuctions[:types] << :characterization if !characterization.attached?
          derivatives_list << instructions if instructions[:types].present?
        elsif audio_access.attached?
          instructions = {}
          instuctions[:source_url] = audio_access_blob.service_url(expires_in: nil, disposition: :attachment)
          instructions[:types] = []
          instructions[:types] << :characterization if !characterization.attached?
          derivatives_list << instructions if instructions[:types].present?
        end

        if document_master.attached? && !document_master.attached?
          instructions = {}
          instuctions[:source_url] = document_master_blob.service_url(expires_in: nil, disposition: :attachment)
          instructions[:types] = []
          instuctions[:types] << :document_access if !document_access.attached?
          derivatives_list << instructions if instructions[:types].present?
        end
      end

      super.merge(derivatives: derivatives_list)
    end
  end
end
