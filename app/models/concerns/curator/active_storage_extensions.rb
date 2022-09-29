# frozen_string_literal: true

module Curator
  module ActiveStorageExtensions
    module AttachmentUploaded
      extend ActiveSupport::Concern

      def uploaded?
        return false if blob.blank?

        blob.uploaded?
      end
    end

    module BlobUploaded
      extend ActiveSupport::Concern

      def uploaded?
        return false if new_record? || key.blank?

        service.exist?(key)
      end
    end

    module AttachedOneUploaded
      extend ActiveSupport::Concern

      def uploaded?
        return false if blank?

        attachment.uploaded?
      end
    end
  end
end
