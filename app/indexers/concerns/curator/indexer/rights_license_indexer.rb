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
            if record.descriptive&.license
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
              context.output_hash['license_ss'] = license.label
              context.output_hash['reuse_allowed_ssi'] = reuse
              context.output_hash['license_uri_ss'] = license.uri
            end
            if record.descriptive&.rights_statement
              rs = record.descriptive.rights_statement
              context.output_hash['rightsstatement_ss'] = rs.label
              context.output_hash['rightsstatement_uri_ss'] = rs.uri
            end
          end
        end
      end
    end
  end
end
