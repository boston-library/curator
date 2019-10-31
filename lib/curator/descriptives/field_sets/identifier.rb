# frozen_string_literal: true

module Curator
  module Descriptives
    class Identifier < FieldSet
      IDENTIFIER_TYPES = ['local-accession', 'local-other', 'local-call', 'local-barcode', 'isbn', 'ismn', 'isrc', 'issn', 'issue-number', 'lccn', 'matrix-number', 'music-plate', 'music-publisher', 'sici', 'videorecording', 'internet-archive'].freeze

      attr_json :label, :string
      attr_json :type, :string
      attr_json :invalid, :boolean, default: false

      validates :type, presence: true, inclusion: {in: IDENTIFIER_TYPES, allow_blank: true }
      validates :label, presence: true
    end
  end
end
