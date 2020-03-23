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

    it 'adds all subject labels to the subject_geographic_* fields' do
      expect(geo_subject_labels - indexed['subject_geographic_tim']).to be_empty
      expect(geo_subject_labels - indexed['subject_geographic_sim']).to be_empty
    end

    let(:parent_geos) { ['Maine', 'Wisconsin', 'Massachusetts', 'United States'] }
    it 'adds parent locations to the subject_geographic_* fields' do
      expect(parent_geos - indexed['subject_geographic_tim']).to be_empty
      expect(parent_geos - indexed['subject_geographic_sim']).to be_empty
    end

    it 'sets the subject_geo_label_sim field' do
      expect(indexed['subject_geo_label_sim']).not_to be_blank
      expect(indexed['subject_geo_label_sim'] - geo_subject_labels).to be_empty
    end

    it 'sets the subject_geo_[hierarchical_place_type]_sim fields' do
      %w(city_section city county state country continent).each do |place_type|
        expect(indexed["subject_geo_#{place_type}_sim"].compact).not_to be_blank
      end
    end

    it 'sets the subject_geo_other_ssm field' do
      expect(indexed['subject_geo_other_ssm']).not_to be_blank
      expect(indexed['subject_geo_other_ssm'].compact - geo_subject_labels).to be_empty
    end

    it 'sets the subject_point_geospatial field' do
      expect(indexed['subject_point_geospatial'].compact.length).to eq(
        descriptive.subject_geos.select { |geo| geo.coordinates.present? }.count
      )
      expect(indexed['subject_point_geospatial'].first).to match /\A-?[0-9.]*,-?[0-9.]*\Z/
    end

    it 'sets the subject_bbox_geospatial field' do
      expect(indexed['subject_bbox_geospatial'].compact.length).to eq(
        descriptive.subject_geos.select { |geo| geo.bounding_box.present? }.count
      )
      expect(indexed['subject_bbox_geospatial'].compact.first).to match(
        /\AENVELOPE\(-?[0-9.]*, -?[0-9.]*, -?[0-9.]*, -?[0-9.]*\)\Z/
      )
    end

    it 'sets the subject_coordinates_geospatial field' do
      expect(indexed['subject_coordinates_geospatial'].compact.length).to eq(
        descriptive.subject_geos.select do |geo|
          geo.coordinates.present? || geo.bounding_box.present?
        end.count
      )
    end

    let(:geojson_facet) { JSON.parse(indexed['subject_geojson_facet_ssim'].first) }
    it 'sets the subject_geojson_facet_ssim field' do
      expect(indexed['subject_geojson_facet_ssim'].length).to eq(
        descriptive.subject_geos.select do |geo|
          geo.coordinates.present? || geo.bounding_box.present?
        end.count
      )
      expect(geojson_facet['type']).to eq 'Feature'
      expect(geojson_facet.dig('geometry', 'coordinates')).to be_a_kind_of Array
    end

    let(:hiergeo_geojson) { JSON.parse(indexed['subject_hiergeo_geojson_ssm'].first) }
    it 'sets the subject_hiergeo_geojson_ssm field' do
      expect(hiergeo_geojson['type']).to eq 'Feature'
      expect(hiergeo_geojson.dig('geometry', 'type')).to eq 'Point'
      expect(hiergeo_geojson.dig('geometry', 'coordinates')).to be_a_kind_of Array
      expect(hiergeo_geojson.dig('properties', 'country')).not_to be_blank
    end
  end
end
