# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::ControlledTerms::AccessConditionModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new).with_keywords(:rights, :access_restrictions) }
  it { is_expected.to respond_to(:wrap_multiple).with(1).argument }

  it 'expects .wrap_multiple to return empty array by default' do
    expect(subject.wrap_multiple).to be_an_instance_of(Array).and be_empty
  end

  describe 'instance' do
    subject { described_class.new(rights: rights) }

    let!(:rights) { Faker::Lorem.sentence }
    let!(:access_restrictions) { Faker::Lorem.sentence }

    it { is_expected.to respond_to(:rights, :access_restrictions, :label, :display_label, :type).with(0).arguments }
    it { is_expected.not_to be_blank }

    context 'with rights' do
      subject { described_class.new(rights: rights) }

      it 'expects #label to eql #rights' do
        expect(subject.label).to eql(subject.rights)
      end

      it 'expects #display_label to eql rights' do
        expect(subject.display_label).to eql('rights')
      end

      it 'expects #type to eql Curator::ControlledTerms::ACCESS_CONDITION_TYPE' do
        expect(subject.type).to eql(Curator::ControlledTerms::ACCESS_CONDITION_TYPE)
      end
    end

    context 'with access_restrictions' do
      subject { described_class.new(access_restrictions: access_restrictions) }

      it 'expects #label to eql #access_restrictions' do
        expect(subject.label).to eql(subject.access_restrictions)
      end

      it 'expects #display_label to be blank' do
        expect(subject.display_label).to be_blank
      end

      it 'expects #type to eql restriction on access' do
        expect(subject.type).to eql('restriction on access')
      end
    end

    context 'with .wrap_multiple' do
      subject { described_class.wrap_multiple(access_condition_attrs) }

      let!(:access_condition_attrs) { [{ rights: rights }, { access_restrictions: access_restrictions }] }

      it { is_expected.to be_a_kind_of(Array).and all(be_an_instance_of(described_class)) }

      it 'is expected to have a #count of 2' do
        expect(subject.count).to be(2)
      end
    end
  end
end
