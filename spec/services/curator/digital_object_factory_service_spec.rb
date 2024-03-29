# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/factory_service_metastreams_shared'

RSpec.describe Curator::DigitalObjectFactoryService, type: :service do
  before(:all) do
    @digital_object_json = load_json_fixture('digital_object')
    # create parent Collection
    parent = create(:curator_collection)
    contained_by = create(:curator_digital_object)
    @digital_object_json['admin_set']['ark_id'] = parent.ark_id
    @digital_object_json['is_member_of_collection'][0]['ark_id'] = parent.ark_id
    @digital_object_json['contained_by']['ark_id'] = contained_by.ark_id
    VCR.use_cassette('services/digital_object_factory_service') do
      expect do
        @success, @digital_object = handle_factory_result(described_class, @digital_object_json)
      end.to change(Curator::DigitalObject, :count).by(1)
    end
  end

  specify { expect(@success).to be_truthy }
  specify { expect(@digital_object).to be_valid }

  describe '#call' do
    subject { @digital_object }

    it 'has the correct properties' do
      expect(subject.ark_id).to eq @digital_object['ark_id']
      expect(subject.created_at).to eq Time.zone.parse(@digital_object_json['created_at'])
    end

    describe 'setting admin set' do
      let(:admin_set) { subject.admin_set }

      it 'creates the admin set relationship' do
        expect(admin_set).to be_an_instance_of(Curator::Collection)
      end
    end

    describe 'setting collection membership' do
      let(:member_of_collection) { subject.is_member_of_collection.first }

      it 'creates the collection membership relationship' do
        expect(member_of_collection).to be_an_instance_of(Curator::Collection)
      end
    end

    describe 'setting conatined by' do
      let(:conatined_by) { subject.contained_by }

      it 'creates the contained by relationship' do
        expect(conatined_by).to be_an_instance_of(Curator::DigitalObject)
      end
    end

    describe 'descriptive metastream' do
      let(:descriptive) { subject.descriptive }
      let(:desc_json)   { @digital_object_json['metastreams']['descriptive'] }
      let(:simple_fields) do
        %w(abstract access_restrictions digital_origin frequency issuance origin_event extent
           physical_location_department physical_location_shelf_locator place_of_publication
           publisher rights series subseries subsubseries toc toc_url resource_type_manuscript
           text_direction)
      end

      specify { expect(descriptive).to be_truthy.and be_valid }

      it 'creates the descriptive object' do
        expect(descriptive).to be_an_instance_of(Curator::Metastreams::Descriptive)
      end

      it 'sets basic metadata properties' do
        simple_fields.each do |attr|
          expect(descriptive.send(attr)).to eq desc_json[attr]
        end
      end

      describe 'json fields' do
        let(:identifiers) { descriptive.identifier }
        it 'sets identifiers' do
          expect(identifiers.count).to eq 3
          expect(identifiers).to all(be_an_instance_of(Curator::DescriptiveFieldSets::Identifier))
          desc_json['identifier'].each do |identifier_json|
            expect(collection_as_json(identifiers, { only: %i(label type) })).to include(identifier_json.except('invalid'))
          end
          expect(identifiers).to include(an_object_having_attributes(invalid: true))
        end

        let(:titles) { descriptive.title }
        it 'creates a TitleSet' do
          expect(titles).to be_an_instance_of(Curator::DescriptiveFieldSets::TitleSet)
        end

        let(:primary_title) { titles.primary }
        let(:title_json) { desc_json['title'] }
        let(:title_attributes) do
          %w(label usage display language subtitle supplied part_name part_number
             id_from_auth authority_code type)
        end

        it 'sets primary title values' do
          expect(primary_title).to be_an_instance_of(Curator::DescriptiveFieldSets::Title)
          title_attributes.each do |attr|
            expect(primary_title.public_send(attr)).to eq title_json['primary'][attr]
          end
        end

        let(:other_titles) { titles.other }
        it 'sets the other title values' do
          expect(other_titles.count).to eq 2
          expect(other_titles).to all(be_an_instance_of(Curator::DescriptiveFieldSets::Title))

          title_json['other'].each do |title_other_json|
            expect(collection_as_json(other_titles, { only: title_attributes })).to include(title_other_json)
          end
        end

        it 'sets date values' do
          expect(descriptive.date).to be_an_instance_of(Curator::DescriptiveFieldSets::Date)
          expect(descriptive.date.created).to eq desc_json['date']['created']
        end

        let(:notes) { descriptive.note }
        it 'sets notes' do
          expect(notes.count).to eq 3
          expect(notes).to all(be_an_instance_of(Curator::DescriptiveFieldSets::Note))
          desc_json['note'].each do |note_json|
            expect(collection_as_json(notes, { only: %i(label type) })).to include(note_json)
          end
        end

        let(:publication) { descriptive.publication }
        let(:pub_json) { desc_json['publication'] }
        it 'sets publication data' do
          expect(publication).to be_an_instance_of(Curator::DescriptiveFieldSets::Publication)
          %w(volume edition_name edition_number issue_number).each do |attr|
            expect(publication.send(attr)).to eq pub_json[attr]
          end
        end

        let(:cartographic) { descriptive.cartographic }
        let(:carto_json) { desc_json['cartographic'] }
        it 'sets cartographic data' do
          expect(cartographic).to be_an_instance_of(Curator::DescriptiveFieldSets::Cartographic)
          expect(cartographic.scale).to eq carto_json['scale']
          expect(cartographic.projection).to eq carto_json['projection']
        end

        let(:related) { descriptive.related }
        let(:related_json) { desc_json['related'] }
        it 'sets related data' do
          expect(related).to be_an_instance_of(Curator::DescriptiveFieldSets::Related)
          expect(related.referenced_by.first).to be_an_instance_of(Curator::DescriptiveFieldSets::ReferencedBy)
          expect(collection_as_json(related.referenced_by)).to eq related_json['referenced_by']
          expect(related.constituent).to eq related_json['constituent']
          expect(related.references_url).to eq related_json['references_url']
          expect(related.other_format).to eq related_json['other_format']
          expect(related.review_url).to eq related_json['review_url']
        end
      end

      describe 'controlled term fields' do
        let(:controlled_term_attrs) { %w(label id_from_auth authority_code) }
        let(:controlled_term_name_attrs) { controlled_term_attrs + %w(name_type) }

        describe 'name_roles' do
          let(:name_roles) { descriptive.name_roles }
          let(:name) { name_roles.first.name }
          let(:role) { name_roles.first.role }
          let(:json_names) { desc_json['name_roles'].map { |nr| nr['name'] } }
          let(:json_roles) { desc_json['name_roles'].map { |nr| nr['role'] } }
          it 'sets the correct number of names and roles' do
            expect(name_roles.count).to eq 3
          end

          it 'sets the name data' do
            expect(name).to be_an_instance_of(Curator::ControlledTerms::Name)
            (controlled_term_name_attrs + %w(affiliation)).each do |attr|
              expect(json_names.collect { |jn| jn[attr] }).to include(name.send(attr))
            end
          end

          it 'sets the role data' do
            expect(role).to be_an_instance_of(Curator::ControlledTerms::Role)
            controlled_term_attrs.each do |attr|
              expect(json_roles.collect { |jr| jr[attr] }).to include(role.send(attr))
            end
          end
        end

        describe 'resource_types' do
          # NOTE: for some reason object order in db is reverse of source JSON
          let(:resource_types) { descriptive.resource_types }
          it 'sets the resource_type data' do
            expect(resource_types.count).to eq 2
            expect(resource_types).to all(be_an_instance_of(Curator::ControlledTerms::ResourceType))
            desc_json['resource_types'].each do |resource_type_json|
              expect(collection_as_json(resource_types, { methods: controlled_term_attrs, only: controlled_term_attrs })).to include(resource_type_json)
            end
          end
        end

        describe 'genres' do
          let(:genres) { descriptive.genres }
          it 'sets the genre data' do
            expect(genres.count).to eq 2
            expect(genres).to all(be_an_instance_of(Curator::ControlledTerms::Genre))
            expect(genres).to satisfy { |g| g.any?(&:basic) }
            desc_json['genres'].each do |genre_json|
              expect(collection_as_json(genres, { methods: controlled_term_attrs, only: controlled_term_attrs })).to include(genre_json.except('basic'))
            end
          end
        end

        describe 'languages' do
          # NOTE: for some reason object order in db is reverse of source JSON
          let(:languages) { descriptive.languages }
          it 'sets the languages data' do
            expect(languages.count).to eq 2
            expect(languages).to all(be_an_instance_of(Curator::ControlledTerms::Language))
            desc_json['languages'].each do |language_json|
              expect(collection_as_json(languages, { methods: controlled_term_attrs, only: controlled_term_attrs })).to include(language_json)
            end
          end
        end

        describe 'ControlledTerms::AccessCondition subclasses' do
          %w(license rights_statement).each do |ac|
            it 'sets the object data' do
              ac_object = descriptive.send(ac)
              expect(ac_object).to be_an_instance_of(Curator.controlled_terms.public_send("#{ac}_class"))
              %i(label uri).each do |attr|
                expect(ac_object.send(attr)).to eq desc_json[ac][attr]
              end
            end
          end
        end

        describe 'physical_location' do
          let(:physical_location) { descriptive.physical_location }
          it 'sets the physical_location data' do
            expect(physical_location).to be_an_instance_of(Curator::ControlledTerms::Name)
            controlled_term_name_attrs.each do |attr|
              expect(physical_location.send(attr)).to eq desc_json['physical_location'][attr]
            end
          end
        end

        describe 'host_collections' do
          let(:host_collections) { descriptive.host_collections }
          let(:host_collection_attributes) { host_collections.map { |hc| { 'name' => hc.name } } }

          it 'sets the host_collection data' do
            expect(host_collections.count).to eq 2
            expect(host_collections).to all(be_an_instance_of(Curator::Mappings::HostCollection))
            expect(host_collection_attributes).to contain_exactly(*desc_json['host_collections'])
          end
        end

        describe 'subject' do
          # NOTE: for some reason object order in db is reverse of source JSON
          let(:subject_topics) { descriptive.subject_topics }

          it 'sets the subject_topic data' do
            expect(subject_topics.count).to eq 3
            expect(subject_topics).to all(be_an_instance_of(Curator::ControlledTerms::Subject))
            desc_json['subject']['topics'].each do |subject_topic_json|
              expect(collection_as_json(subject_topics, { methods: controlled_term_attrs, only: controlled_term_attrs })).to include(subject_topic_json)
            end
          end

          let(:subject_names) { descriptive.subject_names }
          it 'sets the subject_names data' do
            expect(subject_names.count).to eq 2
            expect(subject_names).to all(be_an_instance_of(Curator::ControlledTerms::Name))
            desc_json['subject']['names'].each do |subject_name_json|
              expect(collection_as_json(subject_names, { methods: controlled_term_name_attrs, only: controlled_term_name_attrs })).to include(subject_name_json)
            end
          end

          let(:subject_geos) { descriptive.subject_geos }
          let(:geo_attrs) { controlled_term_attrs + %w(area_type coordinates bounding_box) }
          it 'sets the subject_geos data' do
            expect(subject_geos.count).to eq 8
            expect(subject_geos).to all(be_an_instance_of(Curator::ControlledTerms::Geographic))

            desc_json['subject']['geos'].each do |subject_geo_json|
              expect(collection_as_json(subject_geos, { methods: geo_attrs, only: geo_attrs })).to include(subject_geo_json)
            end
          end

          describe 'subject_other' do
            let(:subject_other) { descriptive.subject_other }
            it 'sets the subject_other data' do
              expect(subject_other).to be_an_instance_of(Curator::DescriptiveFieldSets::Subject)
              expect(subject_other.dates).to contain_exactly(*desc_json['subject']['dates'])
              expect(subject_other.temporals).to contain_exactly(*desc_json['subject']['temporals'])
            end

            describe 'subject_other > title' do
              let(:subject_other_titles) { subject_other.titles }
              let(:subject_other_title_attrs) { controlled_term_attrs + %i(type) }
              it 'sets the subject_other > title data' do
                expect(subject_other_titles).to all(be_an_instance_of(Curator::DescriptiveFieldSets::Title))
                desc_json['subject']['titles'].each do |subject_other_title_json|
                  expect(collection_as_json(subject_other_titles, { methods: subject_other_title_attrs, only: subject_other_title_attrs })).to include(subject_other_title_json)
                end
              end
            end
          end
        end
      end
    end

    it_behaves_like 'factory_workflowable' do
      before(:each) do
        @object_json = @digital_object_json
      end
    end
    it_behaves_like 'factory_administratable' do
      before(:each) do
        @object_json = @digital_object_json
      end
    end

    describe 'administrative metastream' do
      let(:administrative) { subject.administrative }
      let(:administrative_json) { @digital_object_json['metastreams']['administrative'] }
      it 'sets the correct administrative metadata' do
        expect(administrative.description_standard).to eq administrative_json['description_standard']
        expect(administrative.flagged).to eq administrative_json['flagged']
        expect(administrative.hosting_status).to eq(administrative_json['hosting_status'])
      end
    end
  end

  describe 'failure' do
    describe 'invalid data submitted for seeded ControlledTerms values' do
      let!(:bad_digital_object_json) do
        parent = create(:curator_collection)
        bad_obj_json = load_json_fixture('digital_object')
        bad_obj_json.delete('contained_by')
        bad_obj_json['admin_set']['ark_id'] = parent.ark_id
        bad_obj_json['is_member_of_collection'][0]['ark_id'] = parent.ark_id
        bad_obj_json['ark_id'] = 'bpl-dev:xinvalidx'
        bad_obj_json['metastreams']['descriptive']['license']['label'] = 'No rights reserved.'
        bad_obj_json
      end

      it 'returns an error and does not save the record' do
        expect do
          handle_factory_result(described_class, bad_digital_object_json)
        end.to raise_error ActiveRecord::RecordNotSaved
      end
    end
  end
end
