# frozen_string_literal: true

module Curator
  module Metastreams
    module ModsDescriptable
      extend ActiveSupport::Concern

      ResourceTypeWrapper = Struct.new(:resource_type_manuscript, :resource_type)

      included do
        multi_node :title_info, target_obj: ->(obj) { Array.wrap(obj.title.primary) + obj.title.other } do
          attribute :usage
          attribute :type
          attribute :supplied

          element :title, target_val: :label
        end

        multi_node :type_of_resource, target_obj: :map_resource_type_wrappers do
          attribute :manuscript do |obj|
            obj.resource_type_manuscript == true ? 'yes' : nil
          end

          target_value_as do |obj|
            obj.resource_type.label
          end
        end

        multi_node :genre, target_obj: :genres do
          target_value_as :label

          attribute :authority_code, xml_label: :authority

          attribute :authority_base_url, xml_label: :authorityURI

          attribute :value_uri, xml_label: :valueURI
        end

        multi_node :note do
          attribute :type
          target_value_as :label
        end
      end

      def map_resource_type_wrappers(obj)
        obj.resource_types.map { |rt| ResourceTypeWrapper.new(obj.resource_type_manuscript, rt) }
      end
    end
  end
end
