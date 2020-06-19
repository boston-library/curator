# frozen_string_literal: true

module Curator
  module FieldSets
    extend Curator::NamespaceAccessor
    
    IDENTIFIER_TYPES = ['local-accession', 'local-other', 'local-call', 'local-barcode', 'internet-archive', 'isbn', 'ismn', 'isrc', 'issn', 'issue-number', 'lccn', 'matrix-number', 'music-plate', 'music-publisher', 'sici', 'uri', 'videorecording'].freeze
    NOTE_TYPES = ['date', 'language', 'acquisition', 'ownership', 'funding', 'biographical/historical', 'citation/reference', 'preferred citation', 'bibliography', 'exhibitions', 'publications', 'creation/production credits', 'performers', 'physical description', 'venue', 'arrangement', 'statement of responsibility'].freeze
    
    namespace_klass_accessors :cartographic, :date, :identifier, :note, :publication, :related, :subject, :title_set, :title
  end
end