# frozen_string_literal: true

module Curator
  module Filestreams
    module MetadataFoxable
      extend ActiveSupport::Concern
      included do
        has_one_attached :metadata_foxml
      end
    end
  end
end
