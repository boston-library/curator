# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::DescriptiveFieldSets::CartographicModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new).with_keywords(:projection, :bounding_box, :area_type, :coordinates, :scale) }
  it { is_expected.to respond_to(:wrap_multiple).with_keywords(:projection, :scale) }

  describe 'instance' do
    let!(:geographic) { create(:curator_controlled_terms_geographic) }
    let!(:cartographic) { create(:curator_descriptives_cartographic) }

    context 'with geographic subject' do
      subject { described_class.new(**instance_attrs) }

      let!(:instance_attrs) do
        {
          coordinates: geographic.coordinates,
          bounding_box: geographic.bounding_box,
          area_type: geographic.area_type
        }
      end

      it { is_expected.to respond_to(:projection, :bounding_box, :area_type, :cartesian_coords, :coordinates, :scale).with(0).arguments }
      it { is_expected.not_to be_blank }

      it 'expects the instance attributes to have correct values stored' do
        expect(subject.cartesian_coords).to eql(geographic.coordinates)
        expect(subject.bounding_box).to eql(geographic.bounding_box)
        expect(subject.area_type).to eql(geographic.area_type)
        expect(subject.projection).to be(nil)
        expect(subject.scale).to be(nil)
      end

      it 'expects coordinates to  be a String and return and eql bounding_box or cartesian_coords' do
        expect(subject.coordinates).to be_an_instance_of(String)
        expect(subject.coordinates).to eql(geographic.coordinates).or eql(geographic.bounding_box)
      end
    end

    context 'with descriptives cartographic' do
      subject { described_class.new(**instance_attrs) }

      let!(:instance_attrs) do
        {
          projection: cartographic.projection,
          scale: cartographic.scale.first
        }
      end

      it { is_expected.to respond_to(:projection, :bounding_box, :area_type, :cartesian_coords, :coordinates, :scale).with(0).arguments }
      it { is_expected.not_to be_blank }

      it 'expects the instance attributes to have correct values stored' do
        expect(subject.projection).to eql(cartographic.projection)
        expect(subject.scale).to eql(cartographic.scale.first)
        expect(subject.cartesian_coords).to be(nil)
        expect(subject.bounding_box).to be(nil)
        expect(subject.area_type).to be(nil)
      end

      it 'expects coordinates to be blank' do
        expect(subject.coordinates).to be_blank
      end
    end
  end
end
