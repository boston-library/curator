# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::NameRoleIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::NameRoleIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:descriptive) do
      descriptive_ms = create(:curator_metastreams_descriptive)
      create_list(:curator_mappings_desc_name_role, 2).each do |name_role|
        descriptive_ms.name_roles << name_role
      end
      descriptive_ms
    end
    let(:descriptable_object) { descriptive.descriptable }
    let(:indexed) { indexer.map_record(descriptable_object) }

    it 'sets the name field' do
      expect(indexed['name_tsim']).to eq descriptive.name_roles.map { |nr| nr.name.label }
    end

    it 'sets the name_facet field' do
      expect(indexed['name_facet_ssim']).to eq descriptive.name_roles.map { |nr| nr.name.label }
    end

    it 'sets the name_role field' do
      expect(indexed['name_role_tsim']).to eq descriptive.name_roles.map { |nr| nr.role.label }
    end
  end
end
