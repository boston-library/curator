# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_dsl'
RSpec.describe Curator::Serializers::AbstractSerializer, type: :lib_serializers do
  let!(:serializer_class) do
    Class.new(described_class) do
      schema_as_json do
        attributes :id, :updated_at, :created_at
      end
    end
  end
  include_examples 'dsl' do
    let(:described_serializer_class) { serializer_class }
  end
  describe 'class functionality' do
    describe 'inheritance' do
      let(:child_serializer) do
        Class.new(serializer_class) do
          schema_as_json root: :child do
            attribute(:inherited_attribute) { |record| record.created_at.strftime('%b %e/%Y') }
          end
        end
      end

      describe 'root' do
        subject { child_serializer.send(:_schema_for_adapter, :json).root }

        let(:parent_serializer_root) { serializer_class.send(:_schema_for_adapter, :json).root }

        it { is_expected.to be_truthy.and be_a_kind_of(Symbol).and eql(:child) }

        it 'expects the parent serializer class json adapter root to be blank' do
          expect(parent_serializer_root).to be_nil
        end
      end
    end
  end

  describe 'instance functionality' do
    subject { serializer_class.new(record, adapter_key) }

    let(:record) { create(:curator_institution) }
    let(:adapter_key) { :json }

    it { is_expected.to respond_to(:record, :adapter, :serializer_params, :serializable_hash, :render) }
    it { is_expected.to delegate_method(:adapter_serialized_hash).to(:adapter).as(:serializable_hash) }
    it { is_expected.to delegate_method(:adapter_render).to(:adapter).as(:render) }
  end
end
