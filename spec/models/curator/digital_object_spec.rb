# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/mintable'
require_relative './shared/metastreamable'
require_relative './shared/optimistic_lockable'
require_relative './shared/timestampable'
require_relative './shared/for_serialization'
require_relative './shared/local_id_finder'
require_relative './shared/mappings/has_exemplary_file_set'
require_relative './shared/versionable'

RSpec.describe Curator::DigitalObject, type: :model do
  subject { build(:curator_digital_object) }

  it_behaves_like 'mintable'
  it_behaves_like 'versionable'

  describe 'Database' do
    it_behaves_like 'optimistic_lockable'
    it_behaves_like 'timestampable'

    it { is_expected.to have_db_column(:admin_set_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:contained_by_id).of_type(:integer) }
    it { is_expected.to have_db_index(:admin_set_id) }
    it { is_expected.to have_db_index(:contained_by_id) }
    it { is_expected.to have_db_index([:contained_by_id, :id]).unique(true) }
  end

  describe 'Associations' do
    it_behaves_like 'metastreamable_all'
    it_behaves_like 'has_exemplary_file_set'

    let!(:file_sets_class_map) do
      {
        file_sets: 'Curator::Filestreams::FileSet',
        audio_file_sets: 'Curator::Filestreams::Audio',
        image_file_sets: 'Curator::Filestreams::Image',
        document_file_sets: 'Curator::Filestreams::Document',
        ereader_file_sets: 'Curator::Filestreams::Ereader',
        metadata_file_sets: 'Curator::Filestreams::Metadata',
        text_file_sets: 'Curator::Filestreams::Text',
        video_file_sets: 'Curator::Filestreams::Video'
      }
    end

    let!(:file_set_members_class_map) do
      file_sets_class_map.transform_keys { |k| "#{k.to_s.gsub('sets', 'set')}_members".to_sym }
    end

    let!(:file_set_options) do
      {
        inverse_of: :file_set_of,
        foreign_key: :file_set_of_id
      }
    end

    let!(:file_set_member_options) do
      {
        through: :file_set_member_mappings,
        source: :file_set
      }
    end

    it { is_expected.to belong_to(:admin_set).
        inverse_of(:admin_set_objects).
        class_name('Curator::Collection').
        required }

    it { is_expected.to have_one(:institution).
        through(:admin_set).class_name('Curator::Institution') }

    ########### FILE SETS ###################################################
    it 'is expected to have various #file_sets relationships defined' do
      file_sets_class_map.each do |relationship_key, relationship_class|
        expect(subject).to have_many(relationship_key).
                           inverse_of(file_set_options[:inverse_of]).
                           class_name(relationship_class).
                           with_foreign_key(file_set_options[:foreign_key]).
                           dependent(:destroy)
      end
    end

    ##########################################################################

    ################ FILE SET MEMBERS #########################################
    it { is_expected.to have_many(:file_set_member_mappings).
         inverse_of(:digital_object).
         class_name('Curator::Mappings::FileSetMember').
         dependent(:destroy) }

    it 'is expected to have various #file_set_members relationships defined' do
      file_set_members_class_map.each do |relation_key, relation_class|
        expect(subject).to have_many(relation_key).
                           through(file_set_member_options[:through]).
                           source(file_set_member_options[:source]).
                           class_name(relation_class)
      end
    end

    ##########################################################################

    it { is_expected.to have_many(:collection_members).
        inverse_of(:digital_object).
        class_name('Curator::Mappings::CollectionMember').dependent(:destroy) }

    it { is_expected.to have_many(:is_member_of_collection).
        through(:collection_members).source(:collection) }

    describe '#contained_by' do
      let!(:object_contained_by) { create(:curator_digital_object, :with_contained_by) }
      let!(:contained_by) { object_contained_by.contained_by }

      describe 'object contained by behavior' do
        subject { object_contained_by }

        it { is_expected.to belong_to(:contained_by).
                            inverse_of(:container_for).
                            class_name('Curator::DigitalObject').
                            optional }

        it 'expects the contained by to be another digital object' do
          expect(subject.contained_by).to be_an_instance_of(described_class)
        end

        it 'expects digital_object cant be its own contained_by' do
          expect { subject.update!(contained_by: subject) }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      describe 'contained by object behavior' do
        subject { contained_by }

        it do
          is_expected.to have_many(:container_for).
                         inverse_of(:contained_by).
                         class_name('Curator::DigitalObject').
                         with_foreign_key(:contained_by_id).
                         dependent(:nullify)
        end

        it 'is expected to have at least one #contained_for object' do
          expect(subject.container_for.count).to be >= 1
        end
      end
    end
  end

  describe 'Scopes' do
    it_behaves_like 'for_serialization' do
      let(:expected_scope_sql) { described_class.includes(:file_sets, exemplary_image_mapping: :exemplary_file_set).with_metastreams.to_sql }
    end

    describe '.for_reindex_all' do
      subject { described_class }

      let(:expected_scope_sql) { described_class.for_serialization.joins(:administrative, :descriptive, :workflow).to_sql }

      it { is_expected.to respond_to(:for_reindex_all) }

      it 'expects the scope sql to match the :expected_scope_sql' do
        expect(subject.for_reindex_all.to_sql).to eq(expected_scope_sql)
      end
    end

    describe '.issue_objects' do
      subject { described_class }

      let(:expected_scope_sql) { described_class.where.not(contained_by_id: nil).to_sql }

      it { is_expected.to respond_to(:issue_objects) }

      it 'expects the scope sql to match the expected_scope_sql' do
        expect(subject.issue_objects.to_sql).to eq(expected_scope_sql)
      end
    end

    describe '.with_admin_set_ark' do
      subject { described_class }

      let(:admin_set_ark_id) { 'bpl-dev:123456789' }
      let(:expected_scope_sql) { described_class.joins(:admin_set).where(admin_set: { ark_id: admin_set_ark_id }).to_sql }

      it { is_expected.to respond_to(:with_admin_set_ark).with(1).argument }

      it 'expects the scope sql to match the expected_scope_sql' do
        expect(subject.with_admin_set_ark(admin_set_ark_id).to_sql).to eq(expected_scope_sql)
      end
    end

    it_behaves_like 'local_id_finder' do
      let(:admin_set_ark_id) { 'bpl-dev:123456789' }
      let(:identifier) { create_list(:curator_descriptives_identifier, 3).as_json }
      let(:expected_scope_sql) { described_class.joins(:admin_set, :descriptive).where(collections: { ark_id: admin_set_ark_id }).merge(Curator.metastreams.descriptive_class.local_id_finder(identifier)).limit(1).to_sql }
      let(:scope_args) { [admin_set_ark_id, identifier] }
    end

    context 'with #oai_header_id' do
      it_behaves_like 'local_id_finder' do
        let(:admin_set_ark_id) { 'bpl-dev:123456789' }
        let(:identifier_list) { [] }
        let(:oai_header_id) { 'oai:abcd:12345' }
        let(:expected_scope_sql) { described_class.joins(:admin_set, :administrative).where(collections: { ark_id: admin_set_ark_id }).merge(Curator.metastreams.administrative_class.local_id_finder(oai_header_id)).limit(1).to_sql }
        let(:scope_args) { [admin_set_ark_id, identifier_list, oai_header_id] }
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
end
