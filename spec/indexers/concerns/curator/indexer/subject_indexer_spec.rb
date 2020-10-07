# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::SubjectIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::SubjectIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:descriptive) do
      descriptive_ms = create(:curator_metastreams_descriptive)
      create_list(:curator_controlled_terms_subject, 2).each do |topic|
        descriptive_ms.subject_topics << topic
      end
      create_list(:curator_controlled_terms_name, 2).each do |name|
        descriptive_ms.subject_names << name
      end
      descriptive_ms
    end
    let(:descriptable_object) { descriptive.digital_object }
    let(:indexed) { indexer.map_record(descriptable_object) }

    it 'sets the subject_topic field' do
      expect(indexed['subject_topic_tsim']).to eq descriptive.subject_topics.map(&:label)
    end

    it 'sets the subject_name field' do
      expect(indexed['subject_name_tsim']).to eq descriptive.subject_names.map(&:label)
    end

    it 'sets the subject_title field' do
      expect(indexed['subject_title_tsim']).to eq descriptive.subject_other.titles.map(&:label)
    end

    it 'sets the subject_temporal field' do
      expect(indexed['subject_temporal_tsim']).to eq descriptive.subject_other.temporals
    end

    it 'sets the subject_date fields' do
      expect(indexed['subject_date_tsim'].first).to match(/\A\d{4}/)
      expect(indexed['subject_date_start_dtsi'].first).to match(/\A\d{4}-\d{2}-\d{2}T00:00:00.000Z\z/)
      expect(indexed['subject_date_end_dtsi'].first).to match(/\A\d{4}-\d{2}-\d{2}T23:59:59.999Z\z/)
    end

    it 'sets the subject_facet field' do
      expect(indexed['subject_facet_ssim']).to include indexed['subject_topic_tsim'].first
      expect(indexed['subject_facet_ssim']).to include indexed['subject_name_tsim'].last
      expect(indexed['subject_facet_ssim']).to include indexed['subject_title_tsim'].sample
      expect(indexed['subject_facet_ssim']).to include indexed['subject_temporal_tsim'].sample
      expect(indexed['subject_facet_ssim']).to include indexed['subject_date_tsim'].last
    end
  end
end
