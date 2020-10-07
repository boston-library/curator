# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::TitleIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::TitleIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:descriptive) { create(:curator_metastreams_descriptive) }
    let(:descriptable_object) { descriptive.digital_object }
    let(:indexed) { indexer.map_record(descriptable_object) }

    describe 'primary title' do
      it 'sets the title_info_primary label fields' do
        title_string = descriptive.title.primary.label
        expect(indexed['title_info_primary_tsi']).to eq [title_string]
        expect(indexed['title_info_primary_ssort']).to eq [Curator::Parsers::InputParser.get_proper_title(title_string).last]
      end

      it 'sets the subtitle_field' do
        expect(indexed['title_info_primary_subtitle_tsi']).to eq [descriptive.title.primary.subtitle]
      end

      it 'sets the part fields' do
        expect(indexed['title_info_partnum_tsi']).to eq [descriptive.title.primary.part_number]
        expect(indexed['title_info_partname_tsi']).to eq [descriptive.title.primary.part_name]
      end
    end

    describe 'other titles' do
      it 'sets the title_info_alternative field' do
        expect(indexed['title_info_alternative_tsim']).to eq(
          descriptive.title.other.select { |t| t.type == 'alternative' }.map(&:label)
        )
      end

      it 'sets the title_info_uniform field' do
        expect(indexed['title_info_uniform_tsim']).to eq(
          descriptive.title.other.select { |t| t.type == 'uniform' }.map(&:label)
        )
      end

      it 'sets the display label field' do
        expect(indexed['title_info_alternative_label_ssm'].first).to eq descriptive.title.other.first.display
      end

      it 'sets the title_info_other_subtitle field' do
        expect(indexed['title_info_other_subtitle_tsim'].first).to eq descriptive.title.other.first.subtitle
      end
    end
  end
end
