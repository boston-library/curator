# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Metastreams::LocationModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new).with_keywords(:physical_location_name, :holding_simple, :uri_list) }

  describe 'instance' do
    subject { described_class.new(physical_location_name: physical_location_name, holding_simple: holding_simple, uri_list: uri_list) }

    let!(:digital_object) { create(:curator_digital_object) }
    let!(:physical_location_name) { Faker::University.name }
    let!(:holding_simple_attrs) { { sub_location: Faker::Educator.campus, shelf_locator: 'Box 002' } }
    let!(:holding_simple) { Curator::Metastreams::HoldingSimpleModsPresenter.new(**holding_simple_attrs) }
    let!(:uri) { Curator::DescriptiveFieldSets::LocationUrlModsPresenter.new(digital_object.ark_identifier.label, usage: 'primary', access: 'object in context')}
    let!(:uri_list) { Array.wrap(uri) }

    it { is_expected.to respond_to(:physical_location_name, :holding_simple, :uri_list).with(0).arguments }
    it { is_expected.not_to be_blank }

    it 'expects the instance to store the correct values' do
      expect(subject.physical_location_name).to eql(physical_location_name)
      expect(subject.holding_simple).to be_an_instance_of(Curator::Metastreams::HoldingSimpleModsPresenter)
      expect(subject.holding_simple).not_to be_blank
      expect(subject.uri_list).to be_an_instance_of(Array)
      expect(subject.uri_list).to all(be_an_instance_of(Curator::DescriptiveFieldSets::LocationUrlModsPresenter))
    end

    it 'expects #holding_simple#copy_information to have the correct values' do
      expect(subject.holding_simple.copy_information).to be_truthy

      holding_simple_attrs.each do |hs_attr, hs_val|
        expect(subject.holding_simple.copy_information.public_send(hs_attr)).to eql(hs_val)
      end
    end

    it 'expects #uri_list to have the correct values' do
      expect(subject.uri_list[0].url).to eql(digital_object.ark_identifier.label)
      expect(subject.uri_list[0].usage).to eql('primary')
      expect(subject.uri_list[0].access).to eql('object in context')
      expect(subject.uri_list[0].note).to be(nil)
    end
  end
end
