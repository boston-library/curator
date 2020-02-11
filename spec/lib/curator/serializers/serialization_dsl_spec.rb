# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_dsl'
RSpec.describe Curator::Serializers::SerializationDSL, type: :lib_serializer do
  let!(:test_class) { Class.new { include Curator::Serializers::SerializationDSL } }

  describe '.included' do
    subject { test_class }

    it { is_expected.to respond_to(:cache_enabled=, :schema_as_json, :schema_as_xml) }
    it { is_expected.not_to be_cache_enabled }

    describe 'adapter_schemas' do
      subject do
        test_class.schema_as_json { attributes :id }
        test_class.schema_as_xml { attributes :id }
        test_class
      end

      it 'is expected to have adapter schemas' do
        expect(subject.send(:_adapter_schemas)).to be_truthy.and be_a_kind_of(Concurrent::Map)
        expect(subject.send(:_adapter_schemas).keys).to match_array(%i(null json xml))
      end

      it 'is expected to retreive a mapped adapter instance' do
        expect(subject.send(:_schema_for_adapter, :null)).to be_a_kind_of(Curator::Serializers::NullAdapter)
        expect(subject.send(:_schema_for_adapter, :json)).to be_a_kind_of(Curator::Serializers::JSONAdapter)
        expect(subject.send(:_schema_for_adapter, :xml)).to be_a_kind_of(Curator::Serializers::XMLAdapter)
      end

      it 'is expected to reset adapter-schemas' do
        expect { subject.send(:_reset_adapter_schemas!) }.to change { subject.send(:_adapter_schemas).keys.count }
      end

      describe 'with custom adapter registered' do
        subject { Class.new { include Curator::Serializers::SerializationDSL } }

        let!(:custom_adapter) do
          Class.new(Curator::Serializers::AdapterBase) do
            def serializable_hash(_record = nil, _serializer_params = {})
              puts 'I can Serialize A Hash'
            end

            def render(record, serializer_params = {})
              serializable_hash(record, serializer_params)
              puts 'I can render a serialized hash!'
            end
          end
        end

        before(:each) do
          Curator::Serializers.register_adapter(key: :custom, adapter: custom_adapter)
        end

        after(:each) do
          Curator::Serializers.setup! # NOTE: Important to reset the AdapterRegistry after the tests are done to flush test classes
        end

        it 'expects to have dsl method for the adapter' do
          expect(subject).to respond_to(:schema_as_custom)
        end

        it 'expects the adapter will get added' do
          expect do
            subject.schema_as_custom do
              attribute :id
            end
          end.to change { subject.send(:_adapter_schemas).keys.count }.by(1)
          expect(subject.send(:_schema_for_adapter, :custom)).to be_an_instance_of(custom_adapter)
        end
      end
    end
  end

  describe '.inherited' do
    let!(:inheritable_class) do
      Class.new(Curator::Serializers::AbstractSerializer) do
        schema_as_json root: :parent_root do
          attributes :id, :created_at, :updated_at
        end
      end
    end

    let!(:child_class) do
      Class.new(inheritable_class) do
        schema_as_json root: :child_root do
          attributes :foo, :bar
        end
      end
    end

    let!(:inheritable_class_adapter_schemas) { inheritable_class.send(:_adapter_schemas) }
    let!(:child_class_adapter_schemas) { child_class.send(:_adapter_schemas) }
    let!(:schema_object_ids_proc) { ->(val) { val.schema.object_id if val.schema } }
    let!(:schema_facets_object_ids_proc) { ->(val) { val.schema.facets.map(&:object_id) if val.schema } }
    let!(:schema_facets_frozen_proc) { -> (val) { val.schema.facets.map(&:frozen?) if val.schema } }
    describe 'Class initialization' do
      describe 'failure' do
        it 'will raise error if not inherited from the AbstractSerializer Class' do
          expect { Class.new(test_class) }.to raise_error(RuntimeError, /is not inherited from Curator::Serializers::AbstractSerializer/)
        end
      end

      describe 'inherited schema behavior' do
        subject { inheritable_class_adapter_schemas }

        it 'expects the parent/child class to have the same adapters mapped to @_adapter_schemas' do
          expect(subject.keys).to match_array(child_class_adapter_schemas.keys)
          expect(subject.values).to all(be_a_kind_of(Curator::Serializers::AdapterBase))
          expect(child_class_adapter_schemas.values).to all(be_a_kind_of(Curator::Serializers::AdapterBase))
        end

        it 'expects duplicates of @_adapter_schemas values of parent to be mapped to the child serializer' do
          expect(subject.values.map(&:object_id).compact).not_to match_array(child_class_adapter_schemas.values.map(&:object_id).compact) # Adapter Object ids
          expect(subject.values.flat_map(&schema_object_ids_proc).compact).not_to match_array(child_class_adapter_schemas.values.flat_map(&schema_object_ids_proc).compact) # Adapter Schema Object ids
          expect(subject.values.flat_map(&schema_facets_object_ids_proc).compact).not_to match_array(child_class_adapter_schemas.values.flat_map(&schema_facets_object_ids_proc).compact) # Adapter Schema Facet Object Ids
        end

        it 'expects the each facet in the parent/child class @_adpater_schema to be frozen?' do
          # Note: Facets in Schema should ALWAYS be frozen
          expect(subject.values.flat_map(&schema_facets_frozen_proc).compact).to all(be_truthy)
          expect(child_class_adapter_schemas.values.flat_map(&schema_facets_frozen_proc).compact).to all(be_truthy)
        end
      end
    end
  end
end
