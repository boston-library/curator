# frozen_string_literal: true

module Curator
  module ActiveStorageExtensions
    module Blob
      extend ActiveSupport::Concern

      def uploaded?
        return false if new_record? || key.blank?

        service.exist?(key)
      end
    end
  end
end
