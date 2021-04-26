# frozen_string_literal: true

module Curator
  module Filestreams
    module Thumbnailable
      extend ActiveSupport::Concern

      included do
        has_one_attached :image_thumbnail_300, service: :derivatives
      end
    end
  end
end
