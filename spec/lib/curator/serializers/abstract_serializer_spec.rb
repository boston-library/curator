# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_dsl'
RSpec.describe Curator::Serializers::AbstractSerializer, type: :lib_serializers do
  let!(:serializer_class) do
    Class.new(described_class) do
      build_schema_as_json do
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
          build_schema_as_json do
            root_key :child

            attribute(:inherited_attribute) { |record| record.created_at.strftime('%b %e/%Y') }
          end
        end
      end
    end
  end

  describe 'instance functionality' do
    subject { serializer_class.new(record, adapter_key: adapter_key) }

    let(:record) { create(:curator_institution) }
    let(:adapter_key) { :json }

    it { is_expected.to respond_to(:record, :adapter, :params, :serializable_hash, :serialize, :render) }
  end
end
