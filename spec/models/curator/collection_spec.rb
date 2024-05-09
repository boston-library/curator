# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/mintable'
require_relative './shared/metastreamable'
require_relative './shared/optimistic_lockable'
require_relative './shared/timestampable'
require_relative './shared/mappings/has_exemplary_file_set'
require_relative './shared/for_serialization'
require_relative './shared/local_id_finder'

RSpec.describe Curator::Collection, type: :model do
  subject { build(:curator_collection) }

  it_behaves_like 'mintable'

  describe 'Database' do
    it_behaves_like 'optimistic_lockable'
    it_behaves_like 'timestampable'

    it { is_expected.to have_db_column(:institution_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_index(:institution_id) }

    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:abstract).of_type(:text).with_options(default: '') }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'Associations' do
    it_behaves_like 'metastreamable_basic'
    it_behaves_like 'has_exemplary_file_set'

    let!(:file_sets_source_map) do
      [
        :file_sets,
        :audio_file_sets,
        :image_file_sets,
        :document_file_sets,
        :ereader_file_sets,
        :metadata_file_sets,
        :text_file_sets,
        :video_file_sets
      ]
    end

    let!(:file_set_options) do
      {
        through: :admin_set_objects
      }
    end

    it { is_expected.to belong_to(:institution).
      inverse_of(:collections).
      class_name('Curator::Institution').required }

    it { is_expected.to have_many(:admin_set_objects).
        inverse_of(:admin_set).
        class_name('Curator::DigitalObject').with_foreign_key(:admin_set_id).dependent(:destroy) }

    it { is_expected.to have_many(:collection_members).
        inverse_of(:collection).
        class_name('Curator::Mappings::CollectionMember').dependent(:destroy) }

    ########### FILE SETS ###################################################
    it 'is expected to have various #file_sets relationships defined' do
      file_sets_source_map.each do |relation_key|
        expect(subject).to have_many(relation_key).
                           through(file_set_options[:through]).
                           source(relation_key)
      end
    end
  end

  describe 'Scopes' do
    it_behaves_like 'for_serialization' do
      let(:expected_scope_sql) { described_class.includes(exemplary_image_mapping: :exemplary_file_set).with_metastreams.to_sql }
    end

    it_behaves_like 'local_id_finder' do
      let(:collection_name) { "#{Faker::University.name} Collection" }
      let(:institution_ark_id) { 'bpl-dev:12456789' }
      let(:expected_scope_sql) { described_class.joins(:institution).where(institutions: { ark_id: institution_ark_id }, name: collection_name).limit(1).to_sql }
      let(:scope_args) { [institution_ark_id, collection_name] }
    end

    describe '.for_reindex_all' do
      subject { described_class }

      let(:expected_scope_sql) { described_class.for_serialization.joins(:administrative, :workflow).to_sql }

      it { is_expected.to respond_to(:for_reindex_all) }

      it 'expects the scope sql to match the :expected_scope_sql' do
        expect(subject.for_reindex_all.to_sql).to eq(expected_scope_sql)
      end
    end

    describe '#file_sets.exemplaryable' do
      let(:exemplaryable_file_types) { Curator::Mappings::ExemplaryImage::VALID_EXEMPLARY_FILE_SET_TYPES.map { |exemplary_file_type| "Curator::Filestreams::#{exemplary_file_type}" } }
      let(:expected_scope_sql) { subject.file_sets.where(file_set_type: exemplaryable_file_types).to_sql }

      it 'expects the subjects #file_sets to respond_to #exemplaryable' do
        expect(subject.file_sets).to respond_to(:exemplaryable)
      end

      it 'expects subject.file_sets.exemplaryable to eq the expected_scope_sql' do
        expect(subject.file_sets.exemplaryable.to_sql).to eq(expected_scope_sql)
      end
    end
  end

  describe 'Callbacks' do
    describe 'reindex_collection_members' do
      let(:col_for_reindex) { create(:curator_collection) }
      it 'runs the reindex_collection_members callback' do
        col_for_reindex.name = 'Updated Name'
        expect(col_for_reindex).to receive(:reindex_collection_members)
        col_for_reindex.save
      end
    end
  end
end
