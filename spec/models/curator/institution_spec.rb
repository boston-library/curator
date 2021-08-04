# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/mintable'
require_relative './shared/metastreamable'
require_relative './shared/optimistic_lockable'
require_relative './shared/timestampable'
require_relative './shared/archivable'
require_relative './shared/for_serialization'
require_relative './shared/local_id_finder'
require_relative './shared/filestreams/thumbnailable'

RSpec.describe Curator::Institution, type: :model do
  subject { build(:curator_institution) }

  it_behaves_like 'mintable', oai_specific: false

  describe 'Database' do
    it_behaves_like 'optimistic_lockable'
    it_behaves_like 'timestampable'
    it_behaves_like 'archivable'

    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:url).of_type(:string) }
    it { is_expected.to have_db_column(:abstract).of_type(:text).with_options(default: '') }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to allow_values('', nil, 'http://myinstitution.org').for(:url) }
    it { is_expected.not_to allow_value('not a website string').for(:url) }
  end

  describe 'Associations' do
    it_behaves_like 'metastreamable_basic'
    it_behaves_like 'thumbnailable'

    it { is_expected.to belong_to(:location).
      inverse_of(:institution_locations).
      class_name('Curator::ControlledTerms::Geographic').optional }

    it { is_expected.to have_many(:host_collections).
      inverse_of(:institution).class_name('Curator::Mappings::HostCollection').dependent(:destroy) }

    it { is_expected.to have_many(:collections).
      inverse_of(:institution).class_name('Curator::Collection').dependent(:destroy) }

    it { is_expected.to have_many(:collection_admin_set_objects).
      through(:collections).source(:admin_set_objects) }
  end

  describe 'Scopes' do
    describe '.with_location' do
      subject { described_class }

      let(:expected_scope_sql) { described_class.includes(:location).to_sql }

      it { is_expected.to respond_to(:with_location) }

      it 'expects the scope sql to match the :expected_scope_sql' do
        expect(subject.with_location.to_sql).to eq(expected_scope_sql)
      end
    end

    describe '.for_reindex_all' do
      subject { described_class }

      let(:expected_scope_sql) { described_class.for_serialization.joins(:administrative, :workflow).to_sql }

      it { is_expected.to respond_to(:for_reindex_all) }

      it 'expects the scope sql to match the :expected_scope_sql' do
        expect(subject.for_reindex_all.to_sql).to eq(expected_scope_sql)
      end
    end

    it_behaves_like 'for_serialization' do
      let(:expected_scope_sql) { described_class.with_metastreams.with_location.with_attached_image_thumbnail_300.includes(:host_collections).to_sql }
    end

    it_behaves_like 'local_id_finder' do
      let(:institution_name) { Faker::University.name }
      let(:expected_scope_sql) { described_class.where(name: institution_name).limit(1).to_sql }
      let(:scope_args) { Array.wrap(institution_name) }
    end
  end

  describe 'Callbacks' do
    describe 'reindex_associations' do
      let(:inst_for_reindex) { create(:curator_institution) }
      it 'runs the reindex_associations callback' do
        inst_for_reindex.name = 'Updated Name'
        expect(inst_for_reindex).to receive(:reindex_associations)
        inst_for_reindex.save
      end
    end
  end
end
