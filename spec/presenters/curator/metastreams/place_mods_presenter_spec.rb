# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Metastreams::PlaceModsPresenter, type: :presenters do
  subject { described_class }

  specify { expect(subject).to be_const_defined(:PLACE_TERM_MODS_TYPE) }
  specify { expect(subject).to be_const_defined(:PlaceTerm) }

  it { is_expected.to respond_to(:new).with(1).argument }

  describe Curator::Metastreams::PlaceModsPresenter::PlaceTerm do
    subject { described_class }

    it { is_expected.to be <= Struct }
    it { is_expected.to respond_to(:new) }

    # NOTE: Struct initializer arguments/keywords have to be tested this(below) way and won't work with respond_to(...).with_keywords(...)
    it 'is expected to have the following member attributes' do
      expect(subject.members).to include(:label, :type)
    end

    describe 'instance' do
      subject { described_class.new(**place_attrs) }

      let!(:place_attrs) { { label: Faker::University.name, type: Curator::Metastreams::PlaceModsPresenter::PLACE_TERM_MODS_TYPE } }

      it { is_expected.to respond_to(:label, :type).with(0).arguments }

      it 'expects the instance to store the correct values' do
        expect(subject.label).to eql(place_attrs[:label])
        expect(subject.type).to eql(place_attrs[:type])
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(place_of_publication) }

    let!(:place_term_type) { described_class.const_get(:PLACE_TERM_MODS_TYPE) }
    let!(:place_of_publication) { Faker::University.name }

    it { is_expected.to respond_to(:place_term)}

    it 'expects place term  to be a Curator::Metastreams::PlaceModsPresenter::PlaceTerm with the correct values' do
      expect(subject.place_term).to be_present.and be_an_instance_of(Curator::Metastreams::PlaceModsPresenter::PlaceTerm)
      expect(subject.place_term.label).to eql(place_of_publication)
      expect(subject.place_term.type).to eql(place_term_type)
    end
  end
end
