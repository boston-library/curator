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
            next unless record.descriptive&.license

            license = record.descriptive.license
            license_text = license.label.downcase
            reuse = if license_text.include?('public domain') ||
                       license_text.include?('no known restrictions')
                      'no restrictions'
                    elsif license_text.include?('creative commons')
                      'creative commons'
                    elsif license_text.include?('contact host')
                      'contact host'
                    elsif license_text.include?('all rights reserved')
                      'all rights reserved'
                    end
            context.output_hash['license_ss'] = license_text
            context.output_hash['reuse_allowed_ssi'] = reuse
            context.output_hash['license_uri_ss'] = license.uri
          end
        end
      end
    end
  end
end
