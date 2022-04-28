# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_dsl'
RSpec.describe Curator::Serializers::SerializationDSL, type: :lib_serializer do
  let!(:test_class) { Class.new { include Curator::Serializers::SerializationDSL } }

  describe '.included' do
    subject { test_class }

    it { is_expected.to respond_to(:build_schema_as_json, :build_schema_as_xml) }

    describe 'adapter_schemas' do
      subject do
        test_class.build_schema_as_json { attributes :id }
        test_class
      end

      it 'is expected to have adapter schemas' do
        expect(subject.send(:_adapter_schemas)).to be_truthy.and be_a_kind_of(Concurrent::Map)
        expect(subject.send(:_adapter_schemas).keys).to match_array(%i(null json))
      end

      it 'is expected to retreive a mapped adapter instance' do
        expect(subject.send(:_schema_builder_for_adapter, :null)).to be_a_kind_of(Curator::Serializers::NullAdapter)
        expect(subject.send(:_schema_builder_for_adapter, :json)).to be_a_kind_of(Curator::Serializers::JSONAdapter)
        # expect(subject.send(:_schema_for_adapter, :xml)).to be_a_kind_of(Curator::Serializers::XMLAdapter)
      end

      it 'is expected to reset adapter-schemas' do
        expect { subject.send(:_reset_adapter_schemas!) }.to change { subject.send(:_adapter_schemas).keys.count }
      end

      describe 'with custom adapter registered' do
        subject { Class.new { include Curator::Serializers::SerializationDSL } }

        let(:custom_builder_class) do
          Class.new do
            class_attribute :_attributes, instance_accessor: false, default: []

            def self.attributes(*attrs)
              attrs.each { |attr|  _attributes << attr }
            end
          end
        end

        let!(:custom_adapter) do
          Class.new(Curator::Serializers::AdapterBase) do
            def initialize(base_builder_class: custom_builder_class, &_block)
              super(base_builder_class: base_builder_class)
              @schema_builder_class = Class.new(base_builder_class)
            end
            def serializable_hash(_record = nil, _params = {})
              puts 'I can Serialize A Hash'
            end

            def render(record, _params = {})
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
          expect(subject).to respond_to(:build_schema_as_custom)
        end

        it 'expects the adapter will get added' do
          expect do
            subject.build_schema_as_custom do
              attributes :id
            end
          end.to change { subject.send(:_adapter_schemas).keys.count }.by(1)
          expect(subject.send(:_schema_builder_for_adapter, :custom)).to be_an_instance_of(custom_adapter)
        end
      end
    end
  end

  describe '.inherited' do
    let!(:inheritable_class) do
      Class.new(Curator::Serializers::AbstractSerializer) do
        build_schema_as_json do
          root_key :parent_root
          attributes :id, :created_at, :updated_at
        end
      end
    end

    let!(:child_class) do
      Class.new(inheritable_class) do
        build_schema_as_json do
          root_key :child_root
          attributes :foo, :bar
        end
      end
    end

    let!(:inheritable_class_adapter_schemas) { inheritable_class.send(:_adapter_schemas) }
    let!(:child_class_adapter_schemas) { child_class.send(:_adapter_schemas) }

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
      end
    end
  end
end
