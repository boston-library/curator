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
end

RSpec.configure do |config|
  config.include SerializerHelper::FacetHelper, type: :lib_serializers
end
