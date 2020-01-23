# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/optimistic_lockable'
require_relative '../shared/timestampable'
require_relative '../shared/archivable'

RSpec.describe Curator::Metastreams::Descriptive, type: :model do
  subject { create(:curator_metastreams_descriptive) }

  describe 'Database' do
    it_behaves_like 'optimistic_lockable'
    it_behaves_like 'timestampable'
    it_behaves_like 'archivable'
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

    it { is_expected.to have_db_column(:subsubseries).
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

  describe 'attr_json Attributes' do
    let(:json_attributes) { %i(title date publication related cartographic subject_other) }
    let(:array_json_attributes) { %i(identifier note) }
    let(:registry) { described_class.attr_json_registry }
    let(:container_attribute) { ->(json_attribute) { json_attribute == :cartographic ? 'cartographics_json' : (json_attribute == :subject_other ? 'subject_json' : "#{json_attribute}_json") } }
    let(:attr_type) do
      lambda do |type|
        case type
        when :identifier, :note, :date, :publication, :related, :cartographic
          "Curator::Descriptives::#{type.capitalize}".safe_constantize
        when :title
          Curator::Descriptives::TitleSet
        when :subject_other
          Curator::Descriptives::Subject
        else
          NilClass
        end
      end
    end

    it { is_expected.to respond_to(*(json_attributes + array_json_attributes)) }

    describe 'registry settings' do
      it 'expects the the settings for #json_attributes to be set correctly' do
        expect(json_attributes).to all(satisfy { |json_attribute| registry.has_attribute?(json_attribute) })
        expect(json_attributes).to all(satisfy { |json_attribute| registry.fetch(json_attribute).container_attribute == container_attribute.call(json_attribute) })
      end

      it 'expects the settings for #array_json_attributes to be set correctly' do
        expect(array_json_attributes).to all(satisfy { |json_attribute| registry.has_attribute?(json_attribute) })
        expect(array_json_attributes).to all(satisfy { |json_attribute| registry.fetch(json_attribute).container_attribute == container_attribute.call(json_attribute) })
        expect(array_json_attributes).to all(satisfy { |json_attribute| registry.fetch(json_attribute).array_type? })
      end

      describe 'types' do
        it 'expects all the #json_attributes to match the correct types' do
          expect(json_attributes.map { |json_attr| registry.fetch(json_attr).type }).to all(be_a_kind_of(AttrJson::Type::Model))
          json_attributes.each do |json_attribute|
            expect(registry.fetch(json_attribute).type.model).to be(attr_type.call(json_attribute))
          end
        end

        it 'expects all the #array_json_attributes to match the correct_types' do
          expect(array_json_attributes.map { |json_attr| registry.fetch(json_attr).type }).to all(be_a_kind_of(AttrJson::Type::Array))
          expect(array_json_attributes.map { |json_attr| registry.fetch(json_attr).type.base_type }).to all(be_a_kind_of(AttrJson::Type::Model))
          array_json_attributes.each do |json_attribute|
            expect(registry.fetch(json_attribute).type.base_type.model).to be(attr_type.call(json_attribute))
          end
        end

        it "expects the an instance's values to have the correct types" do
          json_attributes.each do |json_attribute|
            expect(subject.send(json_attribute)).to be_an_instance_of(attr_type.call(json_attribute))
          end

          array_json_attributes.each do |json_attribute|
            expect(subject.send(json_attribute)).to be_a_kind_of(Array).and all(be_an_instance_of(attr_type.call(json_attribute)))
          end
        end
      end
    end
  end

  describe 'Associations' do
    let!(:desc_term_mapped_term_class_map) do
      {
        genres: 'Curator::ControlledTerms::Genre',
        resource_types: 'Curator::ControlledTerms::ResourceType',
        licenses: 'Curator::ControlledTerms::License',
        languages: 'Curator::ControlledTerms::Language',
        subject_topics: 'Curator::ControlledTerms::Subject',
        subject_names: 'Curator::ControlledTerms::Name',
        subject_geos: 'Curator::ControlledTerms::Geographic'
      }
    end
    it { is_expected.to belong_to(:descriptable).
                        inverse_of(:descriptive).
                        required }

    it { is_expected.to belong_to(:physical_location).
                        inverse_of(:physical_locations_of).
                        class_name('Curator::ControlledTerms::Name').
                        required }

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

    it { is_expected.to have_many(:desc_terms).
                        inverse_of(:descriptive).
                        class_name('Curator::Mappings::DescTerm').
                        dependent(:destroy) }

    it 'is expected to have various mappings defined :through #desc_terms' do
      desc_term_mapped_term_class_map.each do |relation_key, relation_class|
        expect(subject).to have_many(relation_key).
                           through(:desc_terms).
                           source(:mapped_term).
                           class_name(relation_class)
      end
    end
  end
end
