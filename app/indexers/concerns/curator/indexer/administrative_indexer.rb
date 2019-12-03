# frozen_string_literal: true

module Curator
  class Indexer
    module AdministrativeIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          to_field 'destination_site_ssim', obj_extract('administrative', 'destination_site')
          to_field 'harvesting_status_bsi', obj_extract('administrative', 'harvestable')
          to_field 'flagged_content_ssi' do |record, accumulator|
            accumulator << true if record.administrative.flagged
          end
        end
      end
    end
  end
end
