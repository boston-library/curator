# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module IdentifierIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          each_record do |record, context|
            next unless record.descriptive&.identifier

            id_fields = %w(identifier_local_other_tsim identifier_local_other_invalid_tsim
                           identifier_local_call_tsim identifier_local_call_invalid_tsim
                           identifier_local_barcode_tsim identifier_local_barcode_invalid_tsim
                           identifier_local_accession_tsim identifier_isbn_tsim identifier_lccn_tsim
                           identifier_ia_id_ssi identifier_uri_ss)
            id_fields.each { |field| context.output_hash[field] ||= [] }
            record.descriptive.identifier.each do |identifier|
              label = identifier.label
              id_type = identifier.type.underscore
              if identifier.invalid
                context.output_hash["identifier_#{id_type}_invalid_tsim"] << label
              else
                id_field = case id_type
                           when 'internet_archive'
                             'identifier_ia_id_ssi'
                           when 'uri'
                             'identifier_uri_ss'
                           else
                             "identifier_#{id_type}_tsim"
                           end
                context.output_hash[id_field] << label
              end
            end
          end
        end
      end
    end
  end
end
