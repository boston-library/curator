# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module NameRoleIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          each_record do |record, context|
            name_fields = %w(name_tsim name_role_tsim name_facet_ssim)
            name_fields.each { |field| context.output_hash[field] ||= [] }
            record.descriptive.name_roles.each do |name_role|
              name = name_role.name&.label
              context.output_hash['name_tsim'] << name
              context.output_hash['name_facet_ssim'] << name
              context.output_hash['name_role_tsim'] << name_role.role&.label
            end
          end
        end
      end
    end
  end
end
