# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::DigitalObjectIndexer, type: :indexer do
  describe 'indexing' do
    let(:digital_object) { create(:curator_digital_object, :with_contained_by) }
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

    describe 'exemplary image indexing' do
      # instantiate DigitalObject from :curator_mappings_exemplary_image factory
      # otherwise exemplary_image indexing doesn't work in test env
      let(:exemplary_image_mapping) { create(:curator_mappings_exemplary_image) }
      let(:file_set) { exemplary_image_mapping.exemplary_file_set }
      let(:digital_object) { exemplary_image_mapping.exemplary_object }

      it 'sets the exemplary image field' do
        expect(indexed['exemplary_image_ssi']).to eq [file_set.ark_id]
      end
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
      let(:file_set) { create(:curator_filestreams_image) }
      let(:digital_object) { Curator::DigitalObject.find(file_set.file_set_of_id) }

      it 'sets the filenames field' do
        expect(indexed['filenames_ssim']).to include file_set.file_name_base
      end

      it 'sets the has_searchable_pages and filenames fields' do
        attach_text_file(file_set)
        expect(indexed['has_searchable_pages_bsi']).to be_truthy
      end

      it 'sets the georeferenced field' do
        attach_georeferenced_file(file_set)
        expect(indexed['georeferenced_bsi']).to be_truthy
      end

      describe 'full text indexing' do
        let(:text_file_set) { create(:curator_filestreams_text) }
        let(:digital_object) { Curator::DigitalObject.find(text_file_set.file_set_of_id) }

        it 'sets the ocr field' do
          attach_text_file(text_file_set)
          expect(indexed['ocr_tiv']).to include 'Lorem ipsum'
        end
      end
    end
  end
end
