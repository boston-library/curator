# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module AdministrativeIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          to_field 'destination_site_ssim', obj_extract('administrative', 'destination_site')
          to_field 'hosting_status_ssi', obj_extract('administrative', 'hosting_status')
          to_field 'harvesting_status_bsi', obj_extract('administrative', 'harvestable')
          to_field('flagged_content_ssi') { |rec, acc| acc << true if rec.administrative&.flagged }
        end
      end
    end
  end
end
