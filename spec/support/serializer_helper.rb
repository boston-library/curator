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
      return crush_as_json(record.as_json(options.slice(:root, :include, :only, :methods))) unless record.respond_to?(:metastreams)

      rec_as_json = record.as_json(options.slice(:root, :include, :only, :methods))
      meta_as_json = metastreams_json(record.metastreams, options)

      record_root_key = record_root_key(record)
      if rec_as_json.key?(record_root_key)
        rec_as_json[record_root_key] = rec_as_json[record_root_key].dup.merge(meta_as_json)
        return crush_as_json(rec_as_json)
      end

      rec_as_json = rec_as_json.merge(meta_as_json)
      crush_as_json(rec_as_json)
    end

    def record_root_key(record)
      return record.first.model_name.element.pluralize if record.is_a?(Array) && record.present?

      record.model_name.element
    end

     #use record.metastreams for decorator object
    def metastreams_json(record_metastreams, meta_json_opts = {})
      metastreams = %i(administrative descriptive workflow).inject({}) do |ret, metastream|
        next ret unless record_metastreams.respond_to?(metastream) &&   record_metastreams.public_send(metastream).present?

        as_json_opts = meta_json_opts.fetch(metastream.to_sym, {}).slice(:root, :only, :include, :methods)
        ret.merge(record_metastreams.public_send(metastream).as_json(as_json_opts))
      end

      Hash['metastreams', metastreams]
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
    protected
    #Removes nils from hash
    def crush_as_json(json_data)
      json_data.each_with_object({}) do |(k, v), new_hash|
        unless v.blank?
          v.is_a?(Hash) ? new_hash[k] = crush_as_json(v) : new_hash[k] = v
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include SerializerHelper::FacetHelper, type: :lib_serializers
  config.include SerializerHelper::IntegrationHelper, type: :serializers
end
