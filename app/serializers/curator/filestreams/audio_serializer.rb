# frozen_string_literal: true

module Curator
  class Filestreams::AudioSerializer < Filestreams::FileSetSerializer
    schema_as_json do
      node :audio_master_data, target: -> (record) { record.audio_master_blob } do
        attribute(:id) { |record| record.key }
        node :metadata do
          attributes :byte_size, :checksum
          attribute(:file_name) { |record| record.filename.to_s }
          attribute(:mime_type) { |record| record.content_type.to_s }
        end
      end
    end
  end
end
