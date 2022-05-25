# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Metastreams::HoldingSimpleModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new).with_keywords(:sub_location, :shelf_locator) }

  describe Curator::Metastreams::HoldingSimpleModsPresenter::CopyInformation do
    subject { described_class }

    it { is_expected.to be <= Struct }
    it { is_expected.to respond_to(:new) }

    # NOTE: Struct initializer attributes/keywords have to be tested this(below) way and won't work with respond_to(:new).with_keywords(...)
    it 'is expected to have the following member attributes' do
      expect(subject.members).to include(:sub_location, :shelf_locator)
    end

    describe 'instance' do
      subject { described_class.new(**copy_information_attrs) }

      let!(:copy_information_attrs) { { sub_location: Faker::Educator.campus, shelf_locator: 'Box 001' } }

      it { is_expected.to respond_to(:sub_location, :shelf_locator).with(0).arguments }

      it 'expects the instance to store the correct values' do
        expect(subject.sub_location).to eql(copy_information_attrs[:sub_location])
        expect(subject.shelf_locator).to eql(copy_information_attrs[:shelf_locator])
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(**holding_simple_attrs) }

    let!(:holding_simple_attrs) { { sub_location: Faker::Educator.campus, shelf_locator: 'Box 002' } }

    it { is_expected.to respond_to(:copy_information).with(0).arguments }
    it { is_expected.not_to be_blank }

    it 'expects #copy_information to be a CopyInformation struct with the correct values' do
      expect(subject.copy_information).to be_an_instance_of(Curator::Metastreams::HoldingSimpleModsPresenter::CopyInformation)
      expect(subject.copy_information.sub_location).to eql(holding_simple_attrs[:sub_location])
      expect(subject.copy_information.shelf_locator).to eql(holding_simple_attrs[:shelf_locator])
    end
  end
end
