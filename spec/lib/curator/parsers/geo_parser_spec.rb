# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Parsers::GeoParser do
  subject { described_class }

  describe '#bbox_formatter' do
    let(:valid_bbox) { '-87.6 41.7 -87.5 41.8' }
    let(:invalid_bbox) { '179.0, 89.0, 178.0, 88.0' }
    let(:too_big_bbox) { '-181.0, -91.0, 181.0, 91.0' }
    let(:dateline_bbox) { '144.0 48.0 -116.0 72.0' }

    describe 'wkt_array output' do
      it 'returns a wkt_array' do
        expect(described_class.bbox_formatter(valid_bbox, 'wkt_array')).to eq(
          [[-87.6, 41.7], [-87.5, 41.7], [-87.5, 41.8], [-87.6, 41.8], [-87.6, 41.7]]
        )
        expect(described_class.bbox_formatter(dateline_bbox, 'wkt_array')).to eq(
          [[-216.0, 48.0], [-116.0, 48.0], [-116.0, 72.0], [-216.0, 72.0], [-216.0, 48.0]]
        )
      end
    end

    describe 'wkt_polygon output' do
      it 'returns a wkt_polygon string' do
        expect(described_class.bbox_formatter(valid_bbox, 'wkt_polygon')).to eq(
          'POLYGON((-87.6 41.7, -87.5 41.7, -87.5 41.8, -87.6 41.8, -87.6 41.7))'
        )
      end
    end

    describe 'wkt_envelope output' do
      it 'returns a wkt_envelope string' do
        expect(described_class.bbox_formatter(valid_bbox, 'wkt_envelope')).to eq(
          'ENVELOPE(-87.6, -87.5, 41.8, 41.7)'
        )
        expect(described_class.bbox_formatter(too_big_bbox, 'wkt_envelope')).to eq(
          'ENVELOPE(179.0, -179.0, 90.0, -90.0)'
        )
      end
    end
  end

  describe 'display_placename' do
    let(:other) { { other: 'Worlds End', country: 'United States', state: 'Massachusetts' } }
    let(:city_section) { { city_section: 'Back Bay', country: 'United States', state: 'Massachusetts' } }
    let(:city) { { city: 'Gotham', country: 'United States', state: 'Wisconsin' } }
    let(:county) { { county: 'Suffolk', country: 'United States', state: 'Massachusetts' } }
    let(:non_usa) { { city: 'Accra', country: 'Ghana' } }
    it 'returns a well-formatted location string' do
      expect(described_class.display_placename(other)).to eq 'Worlds End, MA'
      expect(described_class.display_placename(city_section)).to eq 'Back Bay, MA'
      expect(described_class.display_placename(city)).to eq 'Gotham, WI'
      expect(described_class.display_placename(county)).to eq 'Suffolk (county), MA'
      expect(described_class.display_placename(non_usa)).to eq 'Accra, Ghana'
    end
  end

  describe 'normalize_geonames_hgeo' do
    let(:geonames_hgeo) do
      { area: 'Earth', cont: 'North America', pcli: 'United States', adm1: 'Massachusetts',
        adm2: 'Dukes County', adm3: 'Town of Chilmark', bch: 'Lucy Vincent Beach' }
    end
    it 'converts the hgeo hash to TGN-type format' do
      expect(described_class.normalize_geonames_hgeo(geonames_hgeo)).to eq(
        { continent: 'North America', country: 'United States', state: 'Massachusetts',
          county: 'Dukes', city: 'Chilmark', other: 'Lucy Vincent Beach' }
      )
    end
  end

  describe 'normalize_tgn_hgeo' do
    let(:tgn_hgeo) do
      { other: 'Stony Brook (stream)', city_section: 'Roslindale', country: 'United States',
        city: 'Boston', state: 'Massachusetts', county: 'Suffolk' }
    end
    it 'puts the elements in the right order' do
      expect(described_class.normalize_tgn_hgeo(tgn_hgeo)).to eq(
        { country: 'United States', state: 'Massachusetts', county: 'Suffolk',
          city: 'Boston', city_section: 'Roslindale', other: 'Stony Brook (stream)' }
      )
    end
  end
end
