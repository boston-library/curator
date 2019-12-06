# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::DigitalObjectIndexer do
  describe 'indexing' do
    # use DigitalObject from :curator_mappings_exemplary_image factory
    # otherwise exemplary_image indexing doesn't work
    let(:exemplary_image_mapping) do
      create(:curator_mappings_exemplary_image,
             exemplary_object: create(:curator_digital_object),
             exemplary_file_set: create(:curator_filestreams_image))
    end
    let(:digital_object) { exemplary_image_mapping.exemplary_object }
    let(:indexer) { described_class.new }
    let(:indexed) { indexer.map_record(digital_object) }
    let(:collections) { digital_object.is_member_of_collection }

    it 'sets the admin set fields' do
      expect(indexed['admin_set_name_ssi']).to eq [digital_object.admin_set.name]
      expect(indexed['admin_set_ark_id_ssi']).to eq [digital_object.admin_set.ark_id]
    end

    it 'sets the institution fields' do
      %w(institution_name_ssi institution_name_tsi).each do |field|
        expect(indexed[field]).to eq [digital_object.institution.name]
      end
      expect(indexed['institution_ark_id_ssi']).to eq [digital_object.institution.ark_id]
    end

    it 'sets the collection fields' do
      %w(collection_name_ssim collection_name_tsim).each do |field|
        expect(indexed[field]).to eq collections.map { |c| c.name }
      end
      expect(indexed['collection_ark_id_ssim']).to eq collections.map { |c| c.ark_id }
    end

    it 'sets the exemplary image field' do
      expect(indexed['exemplary_image_ssi']).to eq [digital_object.exemplary_file_set.ark_id]
    end
  end
end
