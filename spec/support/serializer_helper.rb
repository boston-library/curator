# frozen_string_literal: true

module SerializerHelper
  module FacetHelper
    def build_facet_inst(klass:, **kwargs, &block)
      klass.new(**kwargs, &block)
    end

    def build_facet_inst_list(*facet_fields, klass:, method: nil, options: {})
      facet_fields.map do |field|
        build_facet_inst(klass: klass, key: field, method: method.blank? ? nil : method.call(field), options: options.dup)
      end
    end

    def serialize_facet_inst(facet_inst, record, options = {})
      return { facet_inst.key => facet_inst.serialize(record, options.dup) } if facet_inst.include_value?(record, options.dup)

      # NOTE: This method simulates how the schema builds the resulting serialized hash.
      nil
    end

    def serialize_facet_inst_collection(*facet_inst_list, record:, options: {})
      facet_inst_list.inject({}) do |ret, facet|
        ret.merge(serialize_facet_inst(facet, record, options.dup))
      end.stringify_keys
    end

    def object_as_json(record, opts = {})
      record.as_json(opts.dup.slice(:only, :include))
    end
  end

  module IntegrationHelper
    def record_as_json(record, options = {})
      record.as_json(options.slice(:only, :include, :root, :except, :method))
    end

    def fetch_transformed_root_key(serializer_instance)
      serializer_instance.adapter.send(:run_root_key_transform, serializer_instance.record)
    end

    def serializer_adapter_schema_attributes(serializer_class, adapter_key, facet_group_key)
      return [] if adapter_key == :null

      serializer_class.send(:_schema_for_adapter, adapter_key)&.
                                                                schema&.
                                                                facet_groups&.
                                                                fetch(facet_group_key, [])&.
                                                                map(&:key)&.
                                                                map(&:to_s)
    end
  end
end

RSpec.configure do |config|
  config.include SerializerHelper::FacetHelper, type: :lib_serializers
  config.include SerializerHelper::IntegrationHelper, type: :serializers
end
