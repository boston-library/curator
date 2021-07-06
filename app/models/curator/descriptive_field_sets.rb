# frozen_string_literal: true

module Curator
  module DescriptiveFieldSets
    extend Curator::NamespaceAccessor

    IDENTIFIER_TYPES = %w(local-accession local-other local-call local-barcode iiif-manifest internet-archive isbn ismn
                          isrc issn issue-number lccn matrix-number music-plate music-publisher sici uri videorecording uri-preview).freeze

    NOTE_TYPES = ['date', 'language', 'acquisition', 'ownership', 'funding', 'biographical/historical',
                  'citation/reference', 'preferred citation', 'bibliography', 'exhibitions', 'publications',
                  'creation/production credits', 'performers', 'physical description', 'venue', 'arrangement',
                  'statement of responsibility'].freeze

    LOCAL_ORIGINAL_IDENTIFIER_TYPES = {
      'internet-archive' => 'barcode',
      'local-barcode' => 'barcode',
      'local-accession' => 'id_local-accession',
      'local-other' => 'id_local-other'
    }.freeze

    namespace_klass_accessors :cartographic, :date, :identifier, :note, :publication, :related, :subject, :title_set, :title
  end
end
