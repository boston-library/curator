# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/versionable'

RSpec.describe Curator::Mappings::HostCollection, type: :model do
  subject { build(:curator_mappings_host_collection) }

  describe 'Database' do
    it { is_expected.to have_db_column(:name).
                      of_type(:string).
                      with_options(null: false) }

    it { is_expected.to have_db_column(:institution_id).
                      of_type(:integer).
                      with_options(null: false) }

    it { is_expected.to have_db_index(:institution_id) }
    it { is_expected.to have_db_index([:name, :institution_id]).unique(true) }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_uniqueness_of(:name).
                        scoped_to(:institution_id) }
  end

  describe 'Scopes' do
    describe '.name_lower' do
      subject { described_class }

      let(:name) { 'Test Collection' }

      let(:expected_scope_sql) { described_class.where('lower(name) = ?', name.downcase).to_sql }

      it { is_expected.to respond_to(:name_lower) }

      it 'expects the scope sql to match the :expected_scope_sql' do
        expect(subject.name_lower(name).to_sql).to eq(expected_scope_sql)
      end
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:institution).
                        inverse_of(:host_collections).
                        class_name('Curator::Institution').
                        required }

    it { is_expected.to have_many(:desc_host_collections).
                        inverse_of(:host_collection).
                        class_name('Curator::Mappings::DescHostCollection').
                        dependent(:destroy) }
  end

  describe 'Callbacks' do
    let(:host_collection) { create(:curator_mappings_host_collection) }
    it 'runs the reindex_descriptable_objects callback' do
      host_collection.name = 'Updated Name'
      expect(host_collection).to receive(:reindex_descriptable_objects)
      host_collection.save
    end
  end

  it_behaves_like 'versionable'
end
