# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module PublicationIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          to_field 'volume_tsi', obj_extract('descriptive', 'publication', 'volume')
          to_field 'edition_name_tsi', obj_extract('descriptive', 'publication', 'edition_name')
          to_field 'edition_number_tsi', obj_extract('descriptive', 'publication', 'edition_number')
          to_field 'issue_number_tsi', obj_extract('descriptive', 'publication', 'issue_number')
        end
      end
    end
  end
end
