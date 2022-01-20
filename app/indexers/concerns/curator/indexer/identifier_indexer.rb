# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module IdentifierIndexer
      extend ActiveSupport::Concern

      ID_FIELDS = %w(local_other_tsim local_other_invalid_tsim local_call_tsim local_call_invalid_tsim
                     local_barcode_tsim local_barcode_invalid_tsim local_accession_tsim isbn_ssim
                     lccn_ssim ia_id_ssi uri_ss iiif_manifest_ss uri_preview_ss issn_ssim ismn_ssim
                     isrc_ssim issue_number_ssim matrix_number_ssim music_plate_ssim music_publisher_ssim
                     sici_ssim videorecording_ssim).freeze
      ID_URI_FIELD = 'identifier_uri_ss'
      included do
        configure do
          each_record do |record, context|
            next unless record.descriptive&.identifier

            if record.administrative.hosting_status == 'hosted' &&
               record.descriptive.identifier.find { |i| i.type == 'uri' }.blank?
              id_uri_value = "#{Curator.config.ark_manager_api_url}/ark:/#{Curator.config.default_ark_params[:namespace_ark]}/#{record.ark_id.split(':').last}"
              context.output_hash[ID_URI_FIELD] = [id_uri_value]
            end

            ID_FIELDS.each { |field| context.output_hash["identifier_#{field}"] ||= [] }
            record.descriptive.identifier.each do |identifier|
              label = identifier.label
              id_type = identifier.type.underscore
              next if id_type == 'local_filename'

              if identifier.invalid
                context.output_hash["identifier_#{id_type}_invalid_tsim"] << label
              else
                id_field = case id_type
                           when 'internet_archive'
                             'identifier_ia_id_ssi'
                           when 'uri'
                             ID_URI_FIELD
                           when 'uri_preview'
                             'identifier_uri_preview_ss'
                           when 'iiif_manifest'
                             'identifier_iiif_manifest_ss'
                           when 'lccn', 'isbn', 'issn', 'ismn', 'isrc', 'issue_number', 'matrix_number', 'music_plate',
                                'music_publisher', 'sici', 'videorecording'
                             "identifier_#{id_type}_ssim"
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
