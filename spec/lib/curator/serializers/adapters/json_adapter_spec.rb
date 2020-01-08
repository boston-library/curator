# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::JSONAdapter, type: :lib_serializers do
  pending
  let!(:record) { create(:curator_institution) }
  let!(:single_item_options) do
    {
      root: :digital_object
    }
  end
  let!(:single_item_json_adapter) do
    described_class.new(single_item_options) do
      attributes :id, :ark_id, :created_at, :updated_at, :name
    end
  end

  describe '#serializable_hash' do
    subject { single_item_json_adapter.serializable_hash(record) }

    it 'should serialize to a hash for a JSON REST API spec' do
      awesome_print subject
    end
  end
end
