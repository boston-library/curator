# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module IdentifierIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          each_record do |record, context|
            next unless record.descriptive&.identifier

            id_uri_field = 'identifier_uri_ss'

            if record.administrative.hosting_status == 'hosted' &&
               record.descriptive.identifier.find { |i| i.type == 'uri' }.blank?
              id_uri_value = "#{Curator.config.ark_manager_api_url}/ark:/#{Curator.config.default_ark_params[:namespace_ark]}/#{record.ark_id.split(':').last}"
              context.output_hash[id_uri_field] = [id_uri_value]
            end

            id_fields = %w(local_other_tsim local_other_invalid_tsim local_call_tsim local_call_invalid_tsim
                           local_barcode_tsim local_barcode_invalid_tsim local_accession_tsim isbn_tsim
                           lccn_tsim ia_id_ssi uri_ss iiif_manifest_ss uri_preview_ss issn_tsim)
            id_fields.each { |field| context.output_hash["identifier_#{field}"] ||= [] }
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
                             id_uri_field
                           when 'uri_preview'
                             'identifier_uri_preview_ss'
                           when 'iiif_manifest'
                             'identifier_iiif_manifest_ss'
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
