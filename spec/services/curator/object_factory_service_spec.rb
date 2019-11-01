require 'rails_helper'
require_relative './factory_service_metastreams_shared'
RSpec.describe Curator::ObjectFactoryService do
  json_fixture = File.join(Curator::Engine.root.join('spec', 'fixtures', 'files', 'digital-object.json'))
  object_json = JSON.parse(File.read(json_fixture)).fetch('digital_object', {})

  before(:all) do
    # create parent Collection
    parent = create(:curator_collection)
    object_json['admin_set']['ark_id'] = parent.ark_id
    object_json['is_member_of_collection'][0]['ark_id'] = parent.ark_id
    expect do
      @object = described_class.call(json_data: object_json)
    end.to change{Curator::DigitalObject.count}.by(1)
  end

  describe '#call' do
    subject { @object }

    it 'has the correct properties' do
      expect(subject.ark_id).to eq object_json['ark_id']
      expect(subject.created_at).to eq Time.zone.parse(object_json['created_at'])
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

    describe 'descriptive metastream' do
      let(:descriptive) { subject.descriptive }
      let(:desc_json) { object_json['metastreams']['descriptive'] }
      let(:simple_fields) do
        %w(abstract access_restrictions digital_origin frequency issuance origin_event extent
           physical_location_department physical_location_shelf_locator place_of_publication
           publisher rights series subseries toc toc_url resource_type_manuscript text_direction)
      end

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
          expect(identifiers.length).to eq 2
          expect(identifiers[0]).to be_an_instance_of(Curator::Descriptives::Identifier)
          expect(identifiers[0].label).to eq desc_json['identifier'][0]['label']
          expect(identifiers[1].type).to eq desc_json['identifier'][1]['type']
          expect(identifiers[1].invalid).to be_truthy
        end

        let(:titles) { descriptive.title }
        it 'creates a TitleSet' do
          expect(titles).to be_an_instance_of(Curator::Descriptives::TitleSet)
        end

        let(:primary_title) { titles.primary }
        it 'sets primary title values' do
          expect(primary_title).to be_an_instance_of(Curator::Descriptives::Title)
          %w(label usage display language subtitle supplied part_name part_number
             id_from_auth authority_code).each do |attr|
            expect(primary_title.send(attr)).to eq desc_json['title_primary'][attr]
          end
        end

        let(:other_titles) { titles.other }
        it 'sets the other title values' do
          expect(other_titles.length).to eq 2
          expect(other_titles[0]).to be_an_instance_of(Curator::Descriptives::Title)
          expect(other_titles[0].label).to eq desc_json['title_other'][0]['label']
          expect(other_titles[1].type).to eq desc_json['title_other'][1]['type']
        end

        it 'sets date values' do
          expect(descriptive.date).to be_an_instance_of(Curator::Descriptives::Date)
          expect(descriptive.date.created).to eq desc_json['date']['created']
        end

        let(:notes) { descriptive.note }
        it 'sets notes' do
          expect(notes.length).to eq 2
          expect(notes[0]).to be_an_instance_of(Curator::Descriptives::Note)
          expect(notes[0].label).to eq desc_json['note'][0]['label']
          expect(notes[1].type).to eq desc_json['note'][1]['type']
        end

        let(:publication) { descriptive.publication }
        it 'sets publication data' do
          expect(publication).to be_an_instance_of(Curator::Descriptives::Publication)
          %w(volume edition_name edition_number issue_number).each do |attr|
            expect(publication.send(attr)).to eq desc_json[attr]
          end
        end

        let(:cartographic) { descriptive.cartographic }
        it 'sets cartographic data' do
          expect(cartographic).to be_an_instance_of(Curator::Descriptives::Cartographic)
          expect(cartographic.scale).to eq desc_json['scale']
          expect(cartographic.projection).to eq desc_json['projection']
        end

        let(:related) { descriptive.related }
        it 'sets related data' do
          expect(related).to be_an_instance_of(Curator::Descriptives::Related)
          expect(related.referenced_by_url).to eq desc_json['related_referenced_by_url']
          expect(related.constituent).to eq desc_json['related_constituent']
        end
      end

      describe 'controlled term fields' do
        let(:controlled_term_attrs) { %w(label id_from_auth authority_code) }
        let(:controlled_term_name_attrs) { controlled_term_attrs + %w(name_type) }

        describe 'name_roles' do
          let(:name_roles) { descriptive.name_roles }
          let(:name) { name_roles[0].name }
          let(:role) { name_roles[0].role }
          it 'sets the correct number of names and roles' do
            expect(name_roles.length).to eq 2
          end
          it 'sets the name data' do
            expect(name).to be_an_instance_of(Curator::ControlledTerms::Name)
            (controlled_term_name_attrs + %w(affiliation)).each do |attr|
              expect(name.send(attr)).to eq desc_json['name_roles'][0]['name'][attr]
            end
          end
          it 'sets the role data' do
            expect(role).to be_an_instance_of(Curator::ControlledTerms::Role)
            controlled_term_attrs.each do |attr|
              expect(role.send(attr)).to eq desc_json['name_roles'][0]['role'][attr]
            end
          end
        end

        describe 'resource_types' do
          # NOTE: for some reason object order in db is reverse of source JSON
          let(:resource_types) { descriptive.resource_types.reverse }
          it 'sets the resource_type data' do
            expect(resource_types.length).to eq 2
            expect(resource_types[0]).to be_an_instance_of(Curator::ControlledTerms::ResourceType)
            controlled_term_attrs.each do |attr|
              expect(resource_types[0].send(attr)).to eq desc_json['resource_types'][0][attr]
            end
          end
        end

        describe 'genres' do
          let(:genres) { descriptive.genres }
          it 'sets the genre data' do
            expect(genres.length).to eq 2
            expect(genres[0]).to be_an_instance_of(Curator::ControlledTerms::Genre)
            (controlled_term_attrs + %w(basic)).each do |attr|
              expect(genres[0].send(attr)).to eq desc_json['genres'][0][attr]
            end
          end
        end

        describe 'languages' do
          # NOTE: for some reason object order in db is reverse of source JSON
          let(:languages) { descriptive.languages.reverse }
          it 'sets the languages data' do
            expect(languages.length).to eq 2
            expect(languages[0]).to be_an_instance_of(Curator::ControlledTerms::Language)
            controlled_term_attrs.each do |attr|
              expect(languages[0].send(attr)).to eq desc_json['languages'][0][attr]
            end
          end
        end

        describe 'licenses' do
          let(:licenses) { descriptive.licenses }
          it 'sets the licenses data' do
            expect(licenses[0]).to be_an_instance_of(Curator::ControlledTerms::License)
            expect(licenses[0].label).to eq desc_json['licenses'][0]['label']
            expect(licenses[0].uri).to eq desc_json['licenses'][0]['uri']
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
          it 'sets the host_collection data' do
            expect(host_collections.length).to eq 2
            expect(host_collections[0]).to be_an_instance_of(Curator::Mappings::HostCollection)
            expect(host_collections[0].name).to eq desc_json['host_collections'][0]
          end
        end

        describe 'subject' do
          # NOTE: for some reason object order in db is reverse of source JSON
          let(:subject_topics) { descriptive.subject_topics.reverse }
          it 'sets the subject_topic data' do
            expect(subject_topics.length).to eq 3
            expect(subject_topics[0]).to be_an_instance_of(Curator::ControlledTerms::Subject)
            controlled_term_attrs.each do |attr|
              expect(subject_topics[0].send(attr)).to eq desc_json['subject']['topics'][0][attr]
            end
          end

          let(:subject_names) { descriptive.subject_names.reverse }
          it 'sets the subject_names data' do
            expect(subject_names.length).to eq 2
            expect(subject_names[0]).to be_an_instance_of(Curator::ControlledTerms::Name)
            controlled_term_name_attrs.each do |attr|
              expect(subject_names[0].send(attr)).to eq desc_json['subject']['names'][0][attr]
            end
          end

          let(:subject_geos) { descriptive.subject_geos.reverse }
          it 'sets the subject_geos data' do
            expect(subject_geos.length).to eq 2
            expect(subject_geos[0]).to be_an_instance_of(Curator::ControlledTerms::Geographic)
            (controlled_term_attrs + %w(coordinates)).each do |attr|
              expect(subject_geos[0].send(attr)).to eq desc_json['subject']['geos'][0][attr]
            end
          end

          describe 'subject_other' do
            let(:subject_other) { descriptive.subject_other }
            it 'sets the subject_other data' do
              expect(subject_other).to be_an_instance_of(Curator::Descriptives::Subject)
              expect(subject_other.dates[0]).to eq desc_json['subject']['dates'][0]
              expect(subject_other.temporals[0]).to eq desc_json['subject']['temporals'][0]
            end

            describe 'subject_other > title' do
              let(:subject_other_title) { subject_other.titles.first }
              it 'sets the subject_other > title data' do
                expect(subject_other_title).to be_an_instance_of(Curator::Descriptives::Title)
                controlled_term_attrs.each do |attr|
                  expect(subject_other_title.send(attr)).to eq desc_json['subject']['titles'][0][attr]
                end
              end
            end
          end
        end
      end
    end

    it_behaves_like 'factory_service_metastreams', object_json

    describe 'administrative metastream' do
      let(:administrative) { subject.administrative }
      let(:administrative_json) { object_json['metastreams']['administrative'] }
      it 'sets the correct administrative metadata' do
        expect(administrative.description_standard).to eq administrative_json['description_standard']
        expect(administrative.flagged).to eq administrative_json['flagged']
      end
    end
  end
end
