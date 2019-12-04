# frozen_string_literal: true

module Curator
  module Descriptives
    extend Curator::NamespaceAccessor
    extend ActiveSupport::Autoload

    IDENTIFIER_TYPES = ['local-accession', 'local-other', 'local-call', 'local-barcode', 'isbn', 'ismn', 'isrc', 'issn', 'issue-number', 'lccn', 'matrix-number', 'music-plate', 'music-publisher', 'sici', 'videorecording', 'internet-archive'].freeze
    NOTE_TYPES = ['date', 'language', 'acquisition', 'ownership', 'funding', 'biographical/historical', 'citation/reference', 'preferred citation', 'bibliography', 'exhibitions', 'publication', 'creation/production credits', 'performers', 'physical-description', 'venue', 'arrangement', 'statement of responsibility'].freeze

    eager_autoload do
      autoload :FieldSet
      autoload_under 'field_sets' do
        autoload :Cartographic
        autoload :Date
        autoload :Identifier
        autoload :Note
        autoload :Publication
        autoload :Related
        autoload :Subject
        autoload :TitleSet
        autoload :Title
      end
    end
    namespace_klass_accessors :cartographic, :date, :identifier, :note, :publication, :related, :subject, :title_set, :title
  end
end
