# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module CartographicIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          to_field 'scale_tsim', obj_extract('descriptive', 'cartographic', 'scale')
          to_field 'projection_tsi', obj_extract('descriptive', 'cartographic', 'projection')
        end
      end
    end
  end
end
