# frozen_string_literal: true

module Curator
  module ActiveStorageExtensions
    module Blob
      extend ActiveSupport::Concern

      def uploaded?
        service.exist?(key)
      end
    end
  end
end
