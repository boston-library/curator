# frozen_string_literal: true

module Curator
  module Serializers
    module SerializationDSL
      extend ActiveSupport::Concern
      included do
        raise "#{self} is not Curator::Serializers::AbstractSerializer" unless Rails.env.test? || _is_serializer?(self)

        class << self
          attr_writer :cache_enabled

          def cache_enabled?
            return @cache_enabled if defined?(@cache_enabled)

            @cache_enabled = false
          end

          protected

          attr_reader :_adapter_schemas
        end
        _reset_adapter_schemas!
        _inject_schema_adapter_methods!
      end

      class_methods do
        def inherited(subclass)
          raise "#{subclass} is not inherited from Curator::Serializers::AbstractSerializer" unless _is_serializer?(subclass)

          super(subclass)
          subclass.cache_enabled = cache_enabled?
          subclass._reset_adapter_schemas!
          subclass._inject_schema_adapter_methods!
          subclass._inherit_schemas!(_adapter_schemas)
        end

        protected

        def _inject_schema_adapter_methods!
          Curator::Serializers.registered_adapter_keys.each { |key| _define_schema_adapter_method(key) }
        end

        def _define_schema_adapter_method(key)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            class << self
              def schema_as_#{key}(root: nil, options: {}, &block)
                _define_adapter_schema(adapter_key: '#{key}'.to_sym, root: root, options: options.dup, &block)
              end
            end
          RUBY
        end

        # NOTE: redefining a schema for an adapter on an inherited class will create a new one
        def _define_adapter_schema(adapter_key:, root: nil, options: {}, &block)
          raise 'NullAdapter cant be used this way' if adapter_key.to_sym == :null

          # TODO: Think of more options to set up at the schema level.
          schema_options = options.dup.slice(:key_transform_method)
          schema_options[:cache_enabled] = cache_enabled?
          schema_options[:cache_options] = options.dup.slice(:cache_key_method, :cached_length, :race_condition_ttyl) if cache_enabled?
          schema_options[:adapter] = adapter_key.to_sym
          schema_options[:root] = root.to_s.to_sym if root

          if _has_schema_adapter?(adapter_key.to_sym)
            adapter_instance = _schema_for_adapter(adapter_key)
            adapter_instance.schema.update_root!(schema_options.dup.fetch(:root, nil))
            adapter_instance.schema.options.merge!(schema_options.dup.except(:root))
            adapter_instance.instance_eval(&block)
          else
            adapter_schema_klass = Curator::Serializers.lookup_adapter(adapter_key.to_sym)
            adapter_instance = adapter_schema_klass.new(schema_options.dup, &block)
          end

          _map_schema_adapter(adapter_key.to_sym, adapter_instance)
        end

        def _schema_for_adapter(adapter_key)
          return _adapter_schemas[adapter_key] if _has_schema_adapter?(adapter_key)

          _adapter_schemas[:null]
        end

        def _is_serializer?(klass)
          klass <= Curator::Serializers::AbstractSerializer
        end

        def _has_schema_adapter?(adapter_key)
          return false unless defined? @_adapter_schemas && !@_adapter_schemas.nil?

          _adapter_schemas.key?(adapter_key)
        end

        def _inherit_schemas!(parent_adapter_schemas)
          # NOTE: We want to make sure that the schema registered in the class is NOT the same instance of the parent class This ensures that it is a different object in memory but preserves the states of all the instance objects on the schema for the adapter
          parent_adapter_schemas.each_pair { |k, v| _adapter_schemas.compute_if_absent(k) { v.deep_dup } }
        end

        def _reset_adapter_schemas!
          return @_adapter_schemas.clear if defined? @_adapter_schemas

          @_adapter_schemas = Concurrent::Map.new if @_adapter_schemas.nil?

          _map_null_adapter
        end

        def _map_null_adapter
          _map_schema_adapter(:null, Curator::Serializers.lookup_adapter(:null).new)
        end

        def _map_schema_adapter(adapter_key, schema_adapter)
          @_adapter_schemas = Concurrent::Map.new unless defined?(@_adapter_schemas) && !@_adapter_schemas.nil?
          _adapter_schemas.merge_pair(adapter_key, schema_adapter) { |v| v }
        end
      end
    end
  end
end
