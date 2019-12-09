# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module PhysicalLocationIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          to_field %w(physical_location_ssim physical_location_tim),
                   obj_extract('descriptive', 'physical_location', 'label')
          to_field 'sub_location_tsi', obj_extract('descriptive', 'physical_location_department')
          to_field 'shelf_locator_tsi', obj_extract('descriptive', 'physical_location_shelf_locator')
        end
      end
    end
  end
end
