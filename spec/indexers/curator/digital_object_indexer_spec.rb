# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::DigitalObjectIndexer, type: :indexer do
  describe 'indexing' do
    let!(:digital_object) { create(:curator_digital_object, :with_contained_by, ark_id: 'bpl-dev:fjdshlfh') }
    let(:indexer) { described_class.new }
    let(:indexed) { indexer.map_record(digital_object) }
    let(:collections) { digital_object.is_member_of_collection }

    it 'sets the admin set fields' do
      expect(indexed['admin_set_name_ssi']).to eq [digital_object.admin_set.name]
      expect(indexed['admin_set_ark_id_ssi']).to eq [digital_object.admin_set.ark_id]
    end

    it 'sets the institution fields' do
      %w(institution_name_ssi institution_name_ti).each do |field|
        expect(indexed[field]).to eq [digital_object.institution.name]
      end
      expect(indexed['institution_ark_id_ssi']).to eq [digital_object.institution.ark_id]
    end

    it 'sets the collection fields' do
      %w(collection_name_ssim collection_name_tim).each do |field|
        expect(indexed[field]).to eq collections.map { |c| c.name }
      end
      expect(indexed['collection_ark_id_ssim']).to eq collections.map { |c| c.ark_id }
    end

    describe 'contained by indexing' do
      let(:contained_by) { digital_object.contained_by }

      it 'sets the contained by field' do
        expect(indexed['contained_by_ssi']).to eq [contained_by.ark_id]
      end
    end

    describe 'attachment-related properties' do
      # instantiate digital_object from file_set.file_set_of_id
      # otherwise file_set-related indexing doesn't work in test env
      # Note needed to create the digital_objects with a static ark id in order to prevent allmaps requests updating the vcr file every time the specs are run
      let(:file_set) { create(:curator_filestreams_image, file_set_of: create(:curator_digital_object, ark_id: 'bpl-dev:asdfghjk')) }
      let(:digital_object) { Curator::DigitalObject.find(file_set.file_set_of_id) }
      let(:indexed) do
        VCR.use_cassette('indexers/digital_object_indexer') do
          indexer.map_record(digital_object)
        end
      end

      it 'sets the filenames field' do
        expect(indexed['filenames_ssim']).to include file_set.file_name_base
      end

      it 'sets the has_searchable_pages fields' do
        attach_text_file(file_set)
        expect(indexed['has_searchable_pages_bsi']).to be_truthy
      end

      describe 'georeferencing properties' do
        it 'sets the georeferenced field' do
          attach_georeferenced_file(file_set)
          expect(indexed['georeferenced_bsi']).to be_truthy
        end

        it 'sets the georeferenced_allmaps field' do
          expect(indexed['georeferenced_allmaps_bsi']).to be_a_kind_of(FalseClass)
        end
      end

      describe 'full text indexing' do
        let(:text_file_set) { create(:curator_filestreams_text, file_set_of: create(:curator_digital_object, ark_id: 'bpl-dev:qwertyu')) }
        let(:digital_object) { Curator::DigitalObject.find(text_file_set.file_set_of_id) }

        before(:each) { attach_text_file(text_file_set) }

        it 'sets the ocr field' do
          expect(indexed['ocr_tiv']).to include 'Lorem ipsum'
        end

        it 'sets the transcription related fields' do
          expect(indexed['has_transcription_bsi']).to be_truthy
          expect(indexed['transcription_ark_id_ssi']).to eql(text_file_set.ark_id)
          expect(indexed['transcription_key_base_ss']).to eql(text_file_set.text_plain_attachment.key.to_s.gsub(/\/[^\/]*\z/, ''))
        end
      end
    end

    describe 'MODS XML indexing' do
      let(:mods_xml) do
        serializer = Curator::DigitalObjectSerializer.new(digital_object, adapter_key: :mods)
        Base64.strict_encode64(Zlib::Deflate.deflate(serializer.serialize))
      end

      it 'sets the mods_xml field' do
        expect(indexed['mods_xml_ss']).to eq mods_xml
      end
    end
  end
end
