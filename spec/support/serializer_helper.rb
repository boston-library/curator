# frozen_string_literal: true

module SerializerHelper
  module AsJsonHelper
    # NOTE: This method return the long list of options used for when #as_json on a descriptive is called of the descriptive as json
    # This is only required when stubbing out an expected value for as json in the descriptive class
    def descriptive_as_json_options
      {
        after_as_json: -> (json_record) { json_record['host_collections'] = json_record['host_collections'].flat_map(&:values) if json_record.key?('host_collections'); json_record },
        root: true,
        only: [:abstract, :digital_origin, :origin_event, :text_direction, :resource_type_manuscript, :place_of_publication, :publisher, :issuance, :frequency, :extent, :physical_location_department, :physical_location_shelf_locator, :series, :subseries, :subsubseries, :rights, :access_restrictions, :toc, :toc_url, :title, :cartographic, :date, :related, :publication],
        include: {
          host_collections: { only: [:name] },
          physical_location: {
            only: [:label, :id_from_auth, :authority_code, :affiliation, :name_type],
            methods: [:label, :id_from_auth, :authority_code, :affiliation, :name_type]
          },
          identifier: {
            only: [:label, :type, :invalid],
            methods: [:label, :type, :invalid]
          },
          note: {
            only: [:label, :type],
            methods: [:label, :type]
          },
          resource_types: {
            only: [:label, :id_from_auth, :authority_code],
            methods: [:label, :id_from_auth, :authority_code]
          },
          genres: {
            only: [:label, :id_from_auth, :basic, :authority_code],
            methods: [:label, :id_from_auth, :basic, :authority_code]
          },
          languages: {
            only: [:label, :id_from_auth, :authority_code],
            methods: [:label, :id_from_auth, :authority_code]
          },
          license: {
            only: [:label, :uri],
            methods: [:label, :uri]
          },
          rights_statement: {
            only: [:label, :uri],
            methods: [:label, :uri]
          },
          subject: {
            methods: [:dates, :temporals],
            include: {
              titles: {
                only: [:label, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :authority_code, :id_from_auth, :part_name, :part_number],
                methods: [:label, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :authority_code, :id_from_auth, :part_name, :part_number]
              },
              topics: {
                only: [:label, :id_from_auth, :authority_code],
                methods: [:label, :id_from_auth, :authority_code]
              },
              names: {
                only: [:label, :id_from_auth, :authority_code, :affiliation, :name_type],
                methods: [:label, :id_from_auth, :authority_code, :affiliation, :name_type]
              },
              geos: {
                only: [:label, :id_from_auth, :authority_code, :bounding_box, :area_type, :coordinates],
                methods: [:label, :id_from_auth, :authority_code, :bounding_box, :area_type, :coordinates]
              }
            }
          },
          name_roles: {
            except: [:id, :descriptive_id, :name_id, :role_id],
            include: {
              name: {
                only: [:label, :id_from_auth, :authority_code, :affiliation, :name_type],
                methods: [:label, :id_from_auth, :authority_code, :affiliation, :name_type]
              },
              role: {
                only: [:label, :id_from_auth, :authority_code],
                methods: [:label, :id_from_auth, :authority_code]
              }
            }
          }
        }
      }
    end
  end

  module SchemaHelper
    def schema_attribute_keys(schema = nil)
      return [] if schema.blank?

      schema.facets.map { |f| f.schema_attribute.key.to_s }
    end

    def schema_attribute_group_keys(schema = nil, facet_group_key = nil)
      return {} if schema.blank?

      return [] if facet_group_key.blank?

      schema.facet_groups.fetch(facet_group_key, []).map { |f| f.key.to_s }
    end
  end

  module FacetHelper
    include SchemaHelper
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
    include SchemaHelper
    include AsJsonHelper
    def record_as_json(record, options = {})
      rec_root_key = record_root_key(record)
      as_json_opts = options.dup.slice(:root, :include, :only, :methods)

      if as_json_opts.fetch(:root, false) && rec_root_key.include?('file_set')
        rec_as_json = record.as_json(as_json_opts)
        key = record.model_name.element

        rec_as_json[rec_root_key] = rec_as_json.delete(key) if rec_as_json.key?(key)
      else
        rec_as_json = record.as_json(as_json_opts)
      end

      return post_process_as_json(rec_as_json, rec_root_key, options) unless record.respond_to?(:metastreams)

      meta_as_json = metastreams_json(record.metastreams, options)

      if rec_as_json.key?(rec_root_key)
        rec_as_json[rec_root_key] = rec_as_json[rec_root_key].dup.merge(meta_as_json)
        return post_process_as_json(rec_as_json, rec_root_key, options)
      end

      rec_as_json = rec_as_json.merge(meta_as_json)
      post_process_as_json(rec_as_json, rec_root_key, options)
    end

    def record_root_key(record)
      for_collection = record.is_a?(Array) || record.kind_of?(ActiveRecord::Relation)
      element_name = for_collection && record.first.present? ? record_element_name(record.first) : record_element_name(record)

      return element_name.to_s.pluralize if for_collection

      element_name
    end

    def record_element_name(record)
      return 'error' if record.kind_of?(Curator::Exceptions::SerializableError)

      record.model_name.singular.include?('filestreams') ? 'file_set' : record.model_name.element
    end

    # NOTE: Use record.metastreams for decorator object
    def metastreams_json(record_metastreams, meta_json_opts = {})
      metastreams = %i(administrative descriptive workflow).inject({}) do |ret, metastream|
        next ret unless record_metastreams.respond_to?(metastream) && record_metastreams.public_send(metastream).present?

        meta_opts = meta_json_opts.fetch(metastream.to_sym, {})
        as_json_opts = meta_opts.dup.slice(:root, :only, :include, :methods)
        record_as_json = record_metastreams.public_send(metastream).as_json(as_json_opts)
        record_as_json = post_process_as_json(record_as_json, metastream.to_s, meta_opts)
        ret.merge(record_as_json)
      end

      Hash['metastreams', metastreams]
    end

    def fetch_transformed_root_key(serializer_instance)
      serializer_instance.adapter.send(:run_root_key_transform, serializer_instance.record)
    end

    def serializer_adapter_schema_attributes(serializer_class, adapter_key, facet_group_key)
      return [] if adapter_key == :null

      schema = serializer_class.send(:_schema_for_adapter, adapter_key)&.schema

      schema_attribute_group_keys(schema, facet_group_key)
    end

    protected

    # helper method for running after_as_json procs to clean up otherwise difficult as json
    # See host_collection proc in descriptive_as_json_options to see what I mean
    def post_process_as_json(as_json_record, root_key, options = {})
      if options.key?(:after_as_json) && options[:after_as_json].respond_to?(:call)
        if root_key && as_json_record.key?(root_key)
          as_json_record[root_key] = options[:after_as_json].call(as_json_record[root_key].dup)
        else
          as_json_record = options[:after_as_json].call(as_json_record.dup)
        end
      end

      return crush_as_json(as_json_record)
    end

    # NOTE: Helper method that recursivley removes blank, nil, and false values hash
    def crush_as_json(hash)
      hash.each_with_object({}) do |(k, v), new_hash|
        if v.present?
          if v.is_a?(Hash)
            new_hash[k] = crush_as_json(v)
          elsif v.is_a?(Array)
            new_hash[k] = v.map { |ve| ve.is_a?(Hash) ? crush_as_json(ve) : ve }
          else
            new_hash[k] = v
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include SerializerHelper::FacetHelper, type: :lib_serializers
  config.include SerializerHelper::IntegrationHelper, type: :serializers
end
