# frozen_string_literal: true

module Curator
  module Filestreams
    module Attacher
      extend ActiveSupport::Concern

      included do
        include AttacherUtils
        include InstanceMethods
      end

      module InstanceMethods

        protected

        def attach_files!(file_set)
          files = @json_data.fetch(:files, [])

          return if files.blank?

          file_set_attachments.each do |attachment_type|

          end
        end

        private

        def file_set_attachments
          file_set_class.attachment_refelctions.keys
        end


        def file_set_class
          return @file_set_class if defined?(@file_set_class)

          @file_set_class = Curator.filestreams.public_send("#{@file_set_type}_class")
        end

      end
    end

    module AttacherUtils
      extend ActiveSupport::Concern

      included do
        include InstanceMethods
      end

      module InstanceMethods
        private

        # format legacy datastream names as ActiveStorage Attachement types
        def attachment_for_ds(datastream_name)
          return if datastream_name.blank?

          attachment_type = datastream_name.underscore
          attachment_type.insert(-4, '_') if datastream_name.match? /(300|800|marcxml)\z/
          attachment_type
        end

        # use fedora content URL if available, or local filepath
        def io_for_file(fedora_content_location, ingest_filepath)
          return if fedora_content_location.blank? && ingest_filepath.blank?

          return File.open(ingest_filepath, 'rb') if ingest_filepath.present?

          opts = {}
          opts[:http_basic_authentication] = [ENV['FEDORA_USERNAME'], ENV['FEDORA_PASSWORD']] if fedora_content_location =~ /FOXML/

          open(fedora_content_location, opts)
        end

        # check ActiveStorage blob attributes against Fedora-exported data, throw error if mismatch
        # @param blob [ActiveStorage::Blob]
        # @param byte_size [Integer] size from incoming file
        # @param checksum_md5 [String] md5 checksum from incoming file
        def check_file_fixity(blob, byte_size, checksum_md5)
          return if byte_size.blank? && checksum_md5.blank?

          if byte_size
            raise ActiveStorage::IntegrityError, "FILE SIZE MISMATCH FOR ActiveStorage::Blob: #{blob.id}" unless blob.byte_size == byte_size
          end
          
          if checksum_md5
            formatted_checksum = Base64.encode64(["#{checksum_md5}"].pack('H*')).chomp
            raise ActiveStorage::IntegrityError, "CHECKSUM MISMATCH FOR ActiveStorage::Blob: #{blob.id}" unless blob.checksum == formatted_checksum
          end
        end
      end
    end
  end
end
