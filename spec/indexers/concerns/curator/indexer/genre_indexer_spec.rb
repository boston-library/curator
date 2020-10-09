# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::GenreIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::GenreIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:descriptive) do
      descriptive_ms = create(:curator_metastreams_descriptive)
      create_list(:curator_controlled_terms_genre, 4).each do |genre|
        descriptive_ms.genres << genre
      end
      descriptive_ms
    end
    let(:descriptable_object) { descriptive.digital_object }
    let(:indexed) { indexer.map_record(descriptable_object) }

    it 'sets the basic genre fields' do
      basic_genres = descriptive.genres.select { |g| g.basic }.map(&:label)
      %w(genre_basic_tim genre_basic_ssim).each do |field|
        expect(indexed[field]).to eq basic_genres
      end
    end

    it 'sets the specific genre fields' do
      specific_genres = descriptive.genres.select { |g| !g.basic }.map(&:label)
      %w(genre_specific_tim genre_specific_ssim).each do |field|
        expect(indexed[field]).to eq specific_genres
      end
    end
  end
end
