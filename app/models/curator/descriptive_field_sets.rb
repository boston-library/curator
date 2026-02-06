# frozen_string_literal: true

module Curator
  module DescriptiveFieldSets
    extend Curator::NamespaceAccessor

    IDENTIFIER_TYPES = %w(iiif-manifest internet-archive isbn ismn isrc issn issue-number lccn
                          local-accession local-barcode local-call local-filename local-other
                          matrix-number music-plate music-publisher oclcnum sici uri uri-preview videorecording).freeze

    NOTE_TYPES = ['acquisition', 'arrangement', 'bibliography', 'biographical/historical', 'citation/reference',
                  'creation/production credits', 'date', 'exhibitions', 'funding', 'language', 'ownership',
                  'performers', 'physical description', 'preferred citation', 'publications',
                  'statement of responsibility', 'venue'].freeze

    INFERRED_DATE_NOTE = 'date is inferred'
    EXCLUDED_MODS_IDENTIFIER_TYPES = %w(iiif-manifest uri-preview local-filename).freeze

    LOCAL_ORIGINAL_IDENTIFIER_TYPES = {
      'local-filename' => 'filename',
      'internet-archive' => 'barcode',
      'local-barcode' => 'barcode',
      'local-accession' => 'id_local-accession',
      'local-other' => 'id_local-other',
      'lccn' => 'id_local-other',
      'oclcnum' => 'id_local-other'
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
