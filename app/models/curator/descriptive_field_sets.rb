# frozen_string_literal: true

module Curator
  module DescriptiveFieldSets
    extend Curator::NamespaceAccessor

    IDENTIFIER_TYPES = %w(local-accession local-other local-call local-barcode local-filename iiif-manifest internet-archive isbn ismn
                          isrc issn issue-number lccn matrix-number music-plate music-publisher sici uri videorecording uri-preview).freeze

    NOTE_TYPES = ['date', 'language', 'acquisition', 'ownership', 'funding', 'biographical/historical',
                  'citation/reference', 'preferred citation', 'bibliography', 'exhibitions', 'publications',
                  'creation/production credits', 'performers', 'physical description', 'venue', 'arrangement',
                  'statement of responsibility'].freeze

    INFERRED_DATE_NOTE = 'date is inferred'
    EXCLUDED_MODS_IDENTIFIER_TYPES = %w(iiif-manifest uri-preview local-filename).freeze

    LOCAL_ORIGINAL_IDENTIFIER_TYPES = {
      'local-filename' => 'filename',
      'internet-archive' => 'barcode',
      'local-barcode' => 'barcode',
      'local-accession' => 'id_local-accession',
      'local-other' => 'id_local-other'
    }.freeze

    RELATED_TYPES = {
      host: 'host',
      constituent: 'constituent',
      series: 'series',
      review: 'reviewOf',
      referenced_by: 'isReferencedBy',
      references: 'references',
      other_format: 'otherFormat'
    }.freeze

    namespace_klass_accessors :cartographic, :date, :identifier, :note, :publication, :related, :subject, :title_set, :title
  end
end
