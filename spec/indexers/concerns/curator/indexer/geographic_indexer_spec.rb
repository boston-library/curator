# frozen_string_literal: true

require 'rails_helper'
include AuthorityFinder
RSpec.describe Curator::Indexer::GeographicIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::GeographicIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    # use geo subjects from digital_object JSON fixture;
    # admittedly brittle, but allows us to test edge cases in source data
    let(:descriptive) do
      descriptive_ms = create(:curator_metastreams_descriptive)
      object_json = load_json_fixture('digital_object')
      geo_subjects = object_json.dig(:metastreams, :descriptive, :subject, :geos) || []
      geo_subjects.each do |geo|
        authority = find_authority_by_code(geo['authority_code'])
        geo[:authority] = authority if authority
        descriptive_ms.subject_geos.build(geo.except('authority_code'))
      end
      descriptive_ms
    end
    let(:descriptable_object) { descriptive.descriptable }
    let(:indexed) do
      VCR.use_cassette('indexers/geographic_indexer') do
        indexer.map_record(descriptable_object)
      end
    end
    let(:geo_subject_labels) { descriptive.subject_geos.map(&:label).compact }

    it 'sets the subject_geographic_tim field' do
      expect(geo_subject_labels - indexed['subject_geographic_tim']).to be_empty
    end

    it 'sets the subject_geographic_sim field' do
      expect(geo_subject_labels - indexed['subject_geographic_sim']).to be_empty
    end

    it 'sets the subject_geo_label_sim field' do
      expect(indexed['subject_geo_label_sim']).not_to be_blank
      expect(indexed['subject_geo_label_sim'] - geo_subject_labels).to be_empty
    end

    it 'sets the subject_geo_[hierarchical_place_type]_sim fields' do
      %w(citysection city county state country continent).each do |place_type|
        puts "subject_geo_#{place_type}_sim = #{indexed["subject_geo_#{place_type}_sim"]}"
        expect(indexed["subject_geo_#{place_type}_sim"]).not_to be_blank
      end
    end

    it 'sets the subject_geo_other_ssm field' do
      puts "subject_geo_other_ssm = #{indexed['subject_geo_other_ssm']}"
      expect(indexed['subject_geo_other_ssm']).not_to be_blank
      expect(indexed['subject_geo_other_ssm'] - geo_subject_labels).to be_empty
    end
  end
end
