# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::ControlledTerms::GeographicModsPresenter, type: :presenters do
  subject { described_class }

  specify { expect(subject).to respond_to(:new).with(1).argument }
  specify { expect(subject).to be_const_defined(:TgnHierGeo) }

  describe Curator::ControlledTerms::GeographicModsPresenter::TgnHierGeo do
    subject { described_class }

    let!(:tgn_hier_geo_attrs) { Curator::Parsers::Constants::TGN_HIER_GEO_ATTRS }

    specify { expect(subject).to respond_to(:new).with_keywords(*tgn_hier_geo_attrs) }

    describe 'instance' do
      subject { described_class.new(**hier_attrs) }

      let!(:hier_attrs) do
        {
          continent: 'North America',
          city: Faker::Address.city,
          city_section: Faker::Address.community,
          province: Faker::Address.state_abbr,
          state: Faker::Address.state,
          territory: 'Lorem',
          county: 'Suffolk',
          island: 'Thimble',
          country: Faker::Address.country,
          area: 'Ipsum',
          region: Faker::Mountain.range,
          extraterrestrial_area: Faker::Space.galaxy
        }
      end

      it { is_expected.to respond_to(:hier_values).with(0).arguments }
      it { is_expected.not_to be_blank }

      it 'is expected to respond_to and have the correct values' do
        tgn_hier_geo_attrs.each do |tgn_hier_geo_attr|
          expect(subject).to respond_to(tgn_hier_geo_attr).with(0).arguments
          expect(subject.public_send(tgn_hier_geo_attr)).to eql(hier_attrs[tgn_hier_geo_attr])
        end
      end

      it 'expects #hier_values to retunr an array of matching values' do
        expect(subject.hier_values).to be_a_kind_of(Array)
        expect(subject.hier_values).to all(be_a_kind_of(String))
        expect(subject.hier_values).to match_array(hier_attrs.values)
      end
    end
  end

  describe 'instance' do
    subject do
      geographic_presenter = nil
      VCR.use_cassette('presenters/controlled_terms/geographic_subject') do
        geographic_presenter = described_class.new(geographic_subject)
      end
      geographic_presenter
    end

    let!(:geographic_subject) { create(:curator_controlled_terms_geographic, :with_tgn_id) }

    it { is_expected.to respond_to(:geographic, :cartographic, :hierarchical_geographic, :label, :display_label, :has_hier_geo?).with(0).arguments }

    it 'is expected to delegate methods to #geographic' do
      expect(subject.geographic).to be_an_instance_of(Curator::ControlledTerms::Geographic)
      expect(subject).to delegate_method(:id_from_auth).to(:geographic).allow_nil
      expect(subject).to delegate_method(:authority_code).to(:geographic).allow_nil
      expect(subject.id_from_auth).to eql(geographic_subject.id_from_auth)
      expect(subject.authority_code).to eql(geographic_subject.authority_code)
    end

    it 'is expected to have a #cartographic with attributes' do
      expect(subject.cartographic).not_to be_blank
      expect(subject.cartographic).to be_an_instance_of(Curator::DescriptiveFieldSets::CartographicModsPresenter)
      expect(subject.cartographic.bounding_box).to eql(geographic_subject.bounding_box)
      expect(subject.cartographic.cartesian_coords).to eql(geographic_subject.coordinates)
    end

    it 'is expected to have a #hierarchical_geographic with attributes' do
      expect(subject).to be_has_hier_geo
      expect(subject.hierarchical_geographic).to be_an_instance_of(Curator::ControlledTerms::GeographicModsPresenter::TgnHierGeo)
    end
  end
end
