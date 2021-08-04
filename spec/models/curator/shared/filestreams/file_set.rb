# frozen_string_literal: true

require_relative '../optimistic_lockable'
require_relative '../timestampable'
require_relative '../mintable'
require_relative '../archivable'
require_relative '../metastreamable'
require_relative '../local_id_finder'
require_relative './characterizable'
require_relative './metadata_foxable'

RSpec.shared_examples 'file_set', type: :model do
  it { is_expected.to be_a_kind_of(Curator::Filestreams::FileSet) }

  describe 'Database' do
    it_behaves_like 'optimistic_lockable'
    it_behaves_like 'timestampable'
    it_behaves_like 'mintable', oai_specific: true, oai_parent: true
    it_behaves_like 'archivable'

    it { is_expected.to have_db_column(:file_set_type).
                        of_type(:string).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:file_name_base).
                        of_type(:string).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:position).
                        of_type(:integer).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:pagination).
                        of_type(:jsonb).
                        with_options(default: '{}') }

    it { is_expected.to have_db_column(:file_set_of_id).
                        of_type(:integer).
                        with_options(null: false) }

    it { is_expected.to have_db_index(:file_set_of_id) }
    it { is_expected.to have_db_index(:file_set_type) }
    it { is_expected.to have_db_index(:position) }
    it { is_expected.to have_db_index(:pagination) }
  end

  describe 'Base Validations' do
    it { is_expected.to validate_presence_of(:file_set_type) }
    it { is_expected.to validate_presence_of(:file_name_base) }
  end

  describe 'Base Associations' do
    it_behaves_like 'metastreamable_basic'

    it { is_expected.to have_many(:file_set_member_of_mappings).
                        inverse_of(:file_set).
                        class_name('Curator::Mappings::FileSetMember').
                        dependent(:destroy) }

    it { is_expected.to have_many(:file_set_members_of).
                        through(:file_set_member_of_mappings).
                        source(:digital_object) }

    describe 'Base File Attachments' do
      it_behaves_like 'characterizable'
      it_behaves_like 'metadata_foxable'
    end
  end

  describe 'Scopes' do
    it_behaves_like 'local_id_finder' do
      let(:file_set_of_ark_id) { 'bpl-dev:123456789' }
      let(:file_name_base) { 'abc123.jpg' }
      let(:expected_scope_sql) { described_class.joins(:file_set_of).where(digital_objects: { ark_id: file_set_of_ark_id }, file_name_base: file_name_base).limit(1).to_sql }
      let(:scope_args) { [file_set_of_ark_id, file_name_base] }
    end
  end

  describe 'Callbacks' do
    describe 'reindex_digital_objects' do
      it 'runs the reindex_digital_objects callback' do
        expect(subject).to receive(:reindex_digital_objects).at_least(:once)
        subject.save
      end
    end
  end
end
