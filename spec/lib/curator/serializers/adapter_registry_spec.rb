# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/singleton'
RSpec.describe Curator::Serializers::AdapterRegistry, type: :lib_serializer do
  subject { described_class.instance }

  let!(:existing_adapters) { %i(json xml null) }

  after(:all) do
    Curator::Serializers.setup! # Important to reset the AdapterRegistry after the tests are done to flush test classes
  end

  it_behaves_like 'singleton'

  it { is_expected.to respond_to(:clear!, :register, :has_adapter?) }

  it 'expects the following adapters to be registered!' do
    expect(existing_adapters).to all(satisfy { |adapter_key| subject.has_adapter?(adapter_key) })
  end

  describe 'registering new adapter' do
    let(:foo_adapter_class) do
      Class.new(Curator::Serializers::AdapterBase) do
        def serializable_hash(_record, _serializer_params = {})
          puts 'I can Serialize A Hash'
        end

        def render(record, serializer_params = {})
          serializable_hash(record, serializer_params)
          puts 'I can render a serialized hash!'
        end
      end
    end

    let(:fail_adapter_class) do
      Class.new do
        def serializable_hash(_record, _serializer_params = {})
          puts 'There is no way I can work because I will never be registered'
        end

        def render(record, serializer_params = {})
          serializable_hash(record, serializer_params)
          puts 'See previous message'
        end
      end
    end

    it 'is expected to fail if the adapter arg is invalid or nil' do
      expect { subject.register(key: :bad_arg, adapter: 'MyBadArgClass') }.to raise_error(RuntimeError, 'No valid adapter class given')
      expect { subject.register(key: :nil_arg, adapter: nil) }.to raise_error(RuntimeError, 'No valid adapter class given')
    end

    it 'is expected to fail if adapter is registered twice' do
      expect { subject.register(key: :null, adapter: 'Curator::Serializers::NullAdapter') }.to raise_error(RuntimeError, 'null for Curator::Serializers::NullAdapter has already been registered!')
    end

    it 'is expected to allow me to register and lookup the new adapter, if it inherits AdapterBase properly' do
      expect(subject.register(key: :foo, adapter: foo_adapter_class)).to be_truthy
      expect(subject).to have_adapter(:foo)
      expect(subject[:foo].object_id).to eq(foo_adapter_class.object_id) # use object_id to ensure the classes are the same
    end

    it 'is expected to fail if the adpater class does not inherit from AdapterBase' do
      expect { subject.register(key: :fail, adapter: fail_adapter_class) }.to raise_error(RuntimeError, "#{fail_adapter_class} is not a kind of Curator::Serializers::AdapterBase!")
    end
  end
end
