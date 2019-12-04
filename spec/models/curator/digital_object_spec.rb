# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/mintable'
require_relative './shared/metastreamable'
require_relative './shared/optimistic_lockable'
require_relative './shared/timestampable'
require_relative './shared/archivable'
require_relative './shared/mappings/has_exemplary_file_set'

RSpec.describe Curator::DigitalObject, type: :model do
  subject { create(:curator_digital_object) }

  it_behaves_like 'mintable'
  it_behaves_like 'optimistic_lockable'
  it_behaves_like 'timestampable'

  describe 'Associations' do
    it_behaves_like 'metastreamable'

    it { is_expected.to have_db_column(:admin_set_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_index(:admin_set_id) }

    let(:file_set_options) do
      {
        inverse_of: :file_set_of,
        foreign_key: :file_set_of_id
      }
    end

    it { is_expected.to belong_to(:admin_set).
        inverse_of(:admin_set_objects).
        class_name('Curator::Collection').
        required }

    ########### FILE SETS ##################
    it { is_expected.to have_many(:audio_file_sets).
        inverse_of(file_set_options[:inverse_of]).
        class_name('Curator::Filestreams::Audio').
        with_foreign_key(file_set_options[:foreign_key]).dependent(:destroy) }

    it { is_expected.to have_many(:image_file_sets).
        inverse_of(file_set_options[:inverse_of]).
        class_name('Curator::Filestreams::Image').
        with_foreign_key(file_set_options[:foreign_key]).dependent(:destroy) }

    it { is_expected.to have_many(:document_file_sets).
        inverse_of(file_set_options[:inverse_of]).
        class_name('Curator::Filestreams::Document').
        with_foreign_key(file_set_options[:foreign_key]).dependent(:destroy) }

    it { is_expected.to have_many(:ereader_file_sets).
        inverse_of(file_set_options[:inverse_of]).
        class_name('Curator::Filestreams::Ereader').
        with_foreign_key(file_set_options[:foreign_key]).dependent(:destroy) }

    it { is_expected.to have_many(:metadata_file_sets).
        inverse_of(file_set_options[:inverse_of]).
        class_name('Curator::Filestreams::Metadata').
        with_foreign_key(file_set_options[:foreign_key]).dependent(:destroy) }

    it { is_expected.to have_many(:text_file_sets).
        inverse_of(file_set_options[:inverse_of]).
        class_name('Curator::Filestreams::Text').
        with_foreign_key(file_set_options[:foreign_key]).dependent(:destroy) }

    it { is_expected.to have_many(:video_file_sets).
        inverse_of(file_set_options[:inverse_of]).
        class_name('Curator::Filestreams::Video').
        with_foreign_key(file_set_options[:foreign_key]).dependent(:destroy) }
    ##########################################################################

    it { is_expected.to have_many(:collection_members).
        inverse_of(:digital_object).
        class_name('Curator::Mappings::CollectionMember').dependent(:destroy) }

    it { is_expected.to have_many(:is_member_of_collection).
        through(:collection_members).source(:collection) }

    it { is_expected.to have_one(:issue_mapping).
        inverse_of(:digital_object).
        class_name('Curator::Mappings::Issue').dependent(:destroy) }

    it { is_expected.to have_one(:issue_mapping_for).
        inverse_of(:issue_of).
        class_name('Curator::Mappings::Issue').
        with_foreign_key(:issue_of_id).dependent(:destroy) }

    it { is_expected.to have_one(:issue_of).
        through(:issue_mapping).
        source(:issue_of).
        class_name('Curator::DigitalObject') }

    it { is_expected.to have_one(:issue_for).
        through(:issue_mapping_for).
        source(:digital_object).
        class_name('Curator::DigitalObject') }
  end

  describe '#institution' do
    it 'returns the parent Institution' do
      expect(subject.institution).to be_an_instance_of Curator::Institution
    end
  end

  it_behaves_like 'has_exemplary_file_set'
end
