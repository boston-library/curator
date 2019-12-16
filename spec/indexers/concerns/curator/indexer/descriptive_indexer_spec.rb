# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::DescriptiveIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::DescriptiveIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:descriptive) do
      descriptive_ms = create(:curator_metastreams_descriptive)
      descriptive_ms.resource_types << create(:curator_controlled_terms_resource_type)
      descriptive_ms.languages << create(:curator_controlled_terms_language)
      descriptive_ms
    end
    let(:descriptable_object) { descriptive.descriptable }
    let(:indexed) { indexer.map_record(descriptable_object) }

    it 'sets the digital_origin field' do
      expect(indexed['digital_origin_ssi']).to eq [descriptive.digital_origin]
    end

    it 'sets the extent field' do
      expect(indexed['extent_tsi']).to eq [descriptive.extent]
    end

    it 'sets the abstract field' do
      expect(indexed['abstract_tsi']).to eq [descriptive.abstract]
    end

    it 'sets the table_of_contents field' do
      expect(indexed['table_of_contents_tsi']).to eq [descriptive.toc]
    end

    it 'sets the table_of_contents_url field' do
      expect(indexed['table_of_contents_url_ss']).to eq [descriptive.toc_url]
    end

    it 'sets the publisher field' do
      expect(indexed['publisher_tsi']).to eq [descriptive.publisher]
    end

    it 'sets the pubplace field' do
      expect(indexed['pubplace_tsi']).to eq [descriptive.place_of_publication]
    end

    it 'sets the issuance field' do
      expect(indexed['issuance_tsi']).to eq [descriptive.issuance]
    end

    it 'sets the frequency field' do
      expect(indexed['frequency_tsi']).to eq [descriptive.frequency]
    end

    it 'sets the text_direction field' do
      expect(indexed['text_direction_ssi']).to eq [descriptive.text_direction]
    end

    it 'sets the resource_type_manuscript field' do
      expect(indexed['resource_type_manuscript_bsi']).to eq [descriptive.resource_type_manuscript]
    end

    it 'sets the type_of_resource field' do
      expect(indexed['type_of_resource_ssim']).to eq descriptive.resource_types.map(&:label)
    end

    it 'sets the lang_term field' do
      expect(indexed['lang_term_ssim']).to eq descriptive.languages.map(&:label)
    end
  end
end
