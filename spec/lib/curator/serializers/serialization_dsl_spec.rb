# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_dsl'
RSpec.describe Curator::Serializers::SerializationDSL, type: :lib_serializer do
  let!(:test_class) { Class.new { include Curator::Serializers::SerializationDSL } }

  describe 'included' do
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

  describe 'inherited' do
    it 'expects to raise error if inherited from anything other than the Abstract Serializer Class' do
      expect { Class.new(test_class) }.to raise_error(RuntimeError, /is not inherited from Curator::Serializers::AbstractSerializer/)
    end
  end
end
