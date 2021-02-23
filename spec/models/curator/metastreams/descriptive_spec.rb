# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/optimistic_lockable'
require_relative '../shared/timestampable'
require_relative '../shared/archivable'
require_relative '../shared/for_serialization'
require_relative '../shared/versionable'

RSpec.describe Curator::Metastreams::Descriptive, type: :model do
  subject { build(:curator_metastreams_descriptive) }

  describe 'Database' do
    it_behaves_like 'optimistic_lockable'
    it_behaves_like 'timestampable'
    it_behaves_like 'archivable'
    it { is_expected.to have_db_column(:digital_object_id).
                        of_type(:integer).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:physical_location_id).
                        of_type(:integer).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:license_id).
                       of_type(:integer).
                       with_options(null: false) }

    it { is_expected.to have_db_column(:rights_statement_id).
                        of_type(:integer) }

    it { is_expected.to have_db_column(:identifier_json).
                        of_type(:jsonb).
                        with_options(default: { 'identifier' => [] }) }

    it { is_expected.to have_db_column(:title).
                        of_type(:jsonb) }

    it { is_expected.to have_db_column(:date).
                        of_type(:jsonb) }

    it { is_expected.to have_db_column(:note_json).
                        of_type(:jsonb).
                        with_options(default: { 'note' => [] }) }

    it { is_expected.to have_db_column(:subject_other).
                        of_type(:jsonb) }

    it { is_expected.to have_db_column(:related).
                        of_type(:jsonb) }

    it { is_expected.to have_db_column(:cartographic).
                        of_type(:jsonb) }

    it { is_expected.to have_db_column(:publication).
                        of_type(:jsonb) }

    it { is_expected.to have_db_column(:digital_origin).
                        of_type(:enum).
                        with_options(default: 'reformatted_digital') }

    it { is_expected.to have_db_column(:text_direction).
                        of_type(:integer) }

    it { is_expected.to have_db_column(:resource_type_manuscript).
                        of_type(:boolean).
                        with_options(default: false) }

    it { is_expected.to have_db_column(:origin_event).
                       of_type(:string) }

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

    it { is_expected.to have_db_index(:digital_object_id).unique(true) }
    it { is_expected.to have_db_index(:physical_location_id) }
    it { is_expected.to have_db_index(:license_id) }
    it { is_expected.to have_db_index(:rights_statement_id) }
    it { is_expected.to have_db_index(:identifier_json) }
    it { is_expected.to have_db_index(:note_json) }
    it { is_expected.to have_db_index(:subject_other) }
    it { is_expected.to have_db_index(:title) }
    it { is_expected.to have_db_index(:date) }
    it { is_expected.to have_db_index(:related) }
    it { is_expected.to have_db_index(:cartographic) }
    it { is_expected.to have_db_index(:publication) }
  end

  describe 'Enum attributes' do
    it { is_expected.to define_enum_for(:digital_origin).
                     with_values(born_digital: 'born_digital', reformatted_digital: 'reformatted_digital', digitized_microfilm: 'digitized_microfilm', digitized_other_analog: 'digitized_other_analog').
                     backed_by_column_of_type(:enum) }

    it { is_expected.to define_enum_for(:text_direction).
                        with_values(%w(ltr rtl)).
                        backed_by_column_of_type(:integer) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:digital_object_id) }
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
          "Curator::DescriptiveFieldSets::#{type.capitalize}".safe_constantize
        when :title
          Curator::DescriptiveFieldSets::TitleSet
        when :subject_other
          Curator::DescriptiveFieldSets::Subject
        else
          NilClass
        end
      end
    end

    it { is_expected.to respond_to(*(json_attributes + array_json_attributes)) }

    describe 'registry settings' do
      it 'expects the settings for #array_json_attributes to be set correctly' do
        expect(array_json_attributes).to all(satisfy { |json_attribute| registry.has_attribute?(json_attribute) })
        expect(array_json_attributes).to all(satisfy { |json_attribute| registry.fetch(json_attribute).container_attribute == container_attribute.call(json_attribute) })
        expect(array_json_attributes).to all(satisfy { |json_attribute| registry.fetch(json_attribute).array_type? })
      end

      describe 'types' do
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
        languages: 'Curator::ControlledTerms::Language',
        subject_topics: 'Curator::ControlledTerms::Subject',
        subject_names: 'Curator::ControlledTerms::Name',
        subject_geos: 'Curator::ControlledTerms::Geographic'
      }
    end
    it { is_expected.to belong_to(:digital_object).
                        inverse_of(:descriptive).
                        class_name('Curator::DigitalObject').
                        touch(true).
                        required }

    it { is_expected.to belong_to(:physical_location).
                        inverse_of(:physical_locations_of).
                        class_name('Curator::ControlledTerms::Name').
                        required }

    it { is_expected.to belong_to(:license).
                       inverse_of(:licensees).
                       class_name('Curator::ControlledTerms::License').
                       required }

    it { is_expected.to belong_to(:rights_statement).
                        inverse_of(:rights_statement_of).
                        class_name('Curator::ControlledTerms::RightsStatement') }

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

  describe 'Scopes' do
    describe '.with_desc_terms' do
      subject { described_class }

      let(:expected_scope_sql) do
        described_class.
        includes(:genres, :resource_types, :languages, :subject_topics, :subject_names, :subject_geos).
        to_sql
      end

      it { is_expected.to respond_to(:with_desc_terms) }

      it 'expects the scope #to_sql to match the :expected_scope_sql' do
        expect(subject.with_desc_terms.to_sql).to eq(expected_scope_sql)
      end
    end

    describe '.with_mappings' do
      subject { described_class }

      let(:expected_scope_sql) do
        described_class.
        includes(:host_collections, :name_roles => [:name, :role]).
        to_sql
      end

      it { is_expected.to respond_to(:with_mappings) }

      it 'expects the scope sql to match the :expected_scope_sql' do
        expect(subject.with_mappings.to_sql).to eq(expected_scope_sql)
      end
    end

    describe '.with_physical_location' do
      subject { described_class }

      let(:expected_scope_sql) { described_class.includes(:physical_location => :authority).to_sql }

      it { is_expected.to respond_to(:with_physical_location) }

      it 'expects the scope sql to match the :expected_scope_sql' do
        expect(subject.with_physical_location.to_sql).to eq(expected_scope_sql)
      end
    end

    describe '.with_license' do
      subject { described_class }

      let(:expected_scope_sql) { described_class.includes(:license).to_sql }

      it { is_expected.to respond_to(:with_license) }

      it 'expects the scope sql to match the :expected_scope_sql' do
        expect(subject.with_license.to_sql).to eq(expected_scope_sql)
      end
    end

    describe '.with_rights_statement' do
      subject { described_class }

      let(:expected_scope_sql) { described_class.includes(:rights_statement).to_sql }

      it { is_expected.to respond_to(:with_rights_statement) }

      it 'expects the scope sql to match the :expected_scope_sql' do
        expect(subject.with_rights_statement.to_sql).to eq(expected_scope_sql)
      end
    end

    it_behaves_like 'for_serialization' do
      let(:expected_scope_sql) do
        described_class.merge(described_class.with_physical_location).merge(described_class.with_license).merge(described_class.with_rights_statement).merge(described_class.with_mappings).merge(described_class.with_desc_terms).to_sql
      end
    end
  end

  it_behaves_like 'versionable'

  describe 'Versioning', versioning: true do
    let(:desc_obj) { create(:curator_metastreams_descriptive, genre_count: 1) }
    let(:new_publisher) { 'foo' }

    before(:each) do
      desc_obj.publisher = new_publisher
      create(:curator_mappings_desc_term, :specific_genre, descriptive: desc_obj)
      desc_obj.save!
    end

    describe 'update' do
      it 'creates a new version' do
        expect(desc_obj.versions.count).to eq 4
        expect(desc_obj.versions.last.reify.publisher).to_not eq new_publisher
      end
    end

    describe 'restoring previous version' do
      it 'resets the object to previous state' do
        version_to_restore = desc_obj.versions[1]
        restored_obj = version_to_restore.reify(has_many: true, has_one: true, belongs_to: true, mark_for_destruction: true)
        desc_obj.reload # avoid StaleObject error
        restored_obj.save!
        expect(restored_obj.publisher).to_not eq new_publisher
        expect(restored_obj.genres.count).to eq 1
      end
    end
  end
end
