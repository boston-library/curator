# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/optimistic_lockable'
require_relative '../shared/timestampable'
require_relative '../shared/archivable'

RSpec.describe Curator::Metastreams::Descriptive, type: :model do
  subject { create(:curator_metastreams_descriptive) }

  it_behaves_like 'optimistic_lockable'
  it_behaves_like 'timestampable'
  it_behaves_like 'archivable'

  describe 'Database columns and indexes' do
    it { is_expected.to have_db_column(:descriptable_type).
                        of_type(:string).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:descriptable_id).
                        of_type(:integer).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:physical_location_id).
                        of_type(:integer).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:identifier_json).
                        of_type(:jsonb).
                        with_options(default: { 'identifier' => [] }, null: false) }

    it { is_expected.to have_db_column(:title_json).
                        of_type(:jsonb).
                        with_options(default: '{}', null: false) }

    it { is_expected.to have_db_column(:date_json).
                        of_type(:jsonb).
                        with_options(default: '{}', null: false) }

    it { is_expected.to have_db_column(:note_json).
                        of_type(:jsonb).
                        with_options(default: { 'note' => [] }, null: false) }

    it { is_expected.to have_db_column(:subject_json).
                        of_type(:jsonb).
                        with_options(default: '{}', null: false) }

    it { is_expected.to have_db_column(:related_json).
                        of_type(:jsonb).
                        with_options(default: '{}', null: false) }

    it { is_expected.to have_db_column(:cartographics_json).
                        of_type(:jsonb).
                        with_options(default: '{}', null: false) }

    it { is_expected.to have_db_column(:publication_json).
                        of_type(:jsonb).
                        with_options(default: '{}', null: false) }

    it { is_expected.to have_db_column(:digital_origin).
                        of_type(:integer).
                        with_options(default: 'reformatted digital', null: false) }

    it { is_expected.to have_db_column(:origin_event).
                        of_type(:integer).
                        with_options(default: 'production', null: false) }

    it { is_expected.to have_db_column(:text_direction).
                        of_type(:integer) }

    it { is_expected.to have_db_column(:resource_type_manuscript).
                        of_type(:boolean).
                        with_options(default: false, null: false) }

    it { is_expected.to have_db_column(:place_of_publication).
                       of_type(:string) }

    it { is_expected.to have_db_column(:publisher).
                        of_type(:string) }

    it { is_expected.to have_db_column(:issuance).
                        of_type(:string) }

    it { is_expected.to have_db_column(:frequency).
                       of_type(:string) }

    it { is_expected.to have_db_column(:extent).
                        of_type(:string) }

    it { is_expected.to have_db_column(:physical_location_department).
                        of_type(:string) }

    it { is_expected.to have_db_column(:physical_location_shelf_locator).
                        of_type(:string) }

    it { is_expected.to have_db_column(:series).
                        of_type(:string) }

    it { is_expected.to have_db_column(:subseries).
                        of_type(:string) }

    it { is_expected.to have_db_column(:rights).
                        of_type(:string) }

    it { is_expected.to have_db_column(:access_restrictions).
                        of_type(:string) }

    it { is_expected.to have_db_column(:toc_url).
                        of_type(:string) }

    it { is_expected.to have_db_column(:toc).
                        of_type(:text).
                        with_options(default: '') }

    it { is_expected.to have_db_column(:abstract).
                        of_type(:text).
                        with_options(default: '') }

    it { is_expected.to have_db_index([:descriptable_type, :descriptable_id]).unique(true) }
    it { is_expected.to have_db_index(:physical_location_id) }
    it { is_expected.to have_db_index(:identifier_json) }
    it { is_expected.to have_db_index(:title_json) }
    it { is_expected.to have_db_index(:date_json) }
    it { is_expected.to have_db_index(:note_json) }
    it { is_expected.to have_db_index(:subject_json) }
    it { is_expected.to have_db_index(:related_json) }
    it { is_expected.to have_db_index(:cartographics_json) }
    it { is_expected.to have_db_index(:publication_json) }
  end

  describe 'Enum attributes' do
    it { is_expected.to define_enum_for(:digital_origin).
                     with_values(['born digital', 'reformatted digital', 'digitized microfilm', 'digitized other analog']).
                     backed_by_column_of_type(:integer) }

    it { is_expected.to define_enum_for(:origin_event).
                        with_values(%w(production publication distribution manufacture)).
                        backed_by_column_of_type(:integer) }

    it { is_expected.to define_enum_for(:text_direction).
                        with_values(%w(ltr rtl)).
                        backed_by_column_of_type(:integer) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:descriptable_id).
                        scoped_to(:descriptable_type) }

    it { is_expected.to allow_value('Curator::DigitalObject').
                        for(:descriptable_type) }

    it { is_expected.to allow_values('http://test.test.com', '', nil).for(:toc_url) }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:descriptable).
                        inverse_of(:descriptive).
                        required }

    it { is_expected.to belong_to(:physical_location).
                        inverse_of(:physical_locations_of).
                        class_name('Curator::ControlledTerms::Name').
                        required }

    it { is_expected.to have_many(:desc_terms).
                        inverse_of(:descriptive).
                        class_name('Curator::Mappings::DescTerm').
                        dependent(:destroy) }

    it { is_expected.to have_many(:name_roles).
                        inverse_of(:descriptive).
                        class_name('Curator::Mappings::DescNameRole').
                        dependent(:destroy) }

    it { is_expected.to have_many(:desc_host_collections).
                        inverse_of(:descriptive).
                        class_name('Curator::Mappings::DescHostCollection').
                        dependent(:destroy) }

    it { is_expected.to have_many(:host_collections).
                        through(:desc_host_collections).
                        source(:host_collection) }

    it { is_expected.to have_many(:genres).
                        through(:desc_terms).
                        source(:mappable) }

    it { is_expected.to have_many(:resource_types).
                        through(:desc_terms).
                        source(:mappable) }

    it { is_expected.to have_many(:licenses).
                        through(:desc_terms).
                        source(:mappable) }

    it { is_expected.to have_many(:languages).
                        through(:desc_terms).
                        source(:mappable) }

    it { is_expected.to have_many(:subject_topics).
                        through(:desc_terms).
                        source(:mappable) }

    it { is_expected.to have_many(:subject_names).
                        through(:desc_terms).
                        source(:mappable) }

    it { is_expected.to have_many(:subject_geos).
                        through(:desc_terms).
                        source(:mappable) }
  end
end
