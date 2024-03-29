# frozen_string_literal: true

module Curator
  module Metastreams
    module AdministratableJson
      extend ActiveSupport::Concern

      included do
        attributes :description_standard, :flagged, :harvestable, :destination_site, :oai_header_id, :hosting_status
      end
    end
  end
end
