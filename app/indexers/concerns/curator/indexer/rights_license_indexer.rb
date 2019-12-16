# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module RightsLicenseIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          to_field 'rights_ss', obj_extract('descriptive', 'rights')
          to_field 'restrictions_on_access_ss', obj_extract('descriptive', 'access_restrictions')
          each_record do |record, context|
            next unless record.descriptive&.licenses

            license_fields = %w(license_ssm license_uri_ssm reuse_allowed_ssi)
            license_fields.each { |field| context.output_hash[field] ||= [] }
            record.descriptive.licenses.each do |license|
              license_text = license.label
              reuse = if license_text.downcase.include?('public domain') ||
                         license_text.downcase.include?('no known restrictions')
                        'no restrictions'
                      elsif license_text.downcase.include?('creative commons')
                        'creative commons'
                      elsif license_text.downcase.include?('contact host')
                        'contact host'
                      elsif license_text.downcase.include?('all rights reserved')
                        'all rights reserved'
                      end
              context.output_hash['license_ssm'] << license_text
              context.output_hash['reuse_allowed_ssi'] << reuse
              context.output_hash['license_uri_ssm'] << license.uri
            end
          end
        end
      end
    end
  end
end
