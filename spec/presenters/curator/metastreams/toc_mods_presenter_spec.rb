# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Metastreams::TocModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new, :wrap_multiple).with_keywords(:label, :xlink) }

  it 'expects .wrap_multiple to return empty array by default' do
    expect(subject.wrap_multiple).to be_an_instance_of(Array).and be_empty
  end

  describe 'instance' do
    let!(:label) { '1. fol. 1: blank. -- 2. fol. 1v-2: Slightly later additions' }
    let!(:xlink) { Faker::Internet.url(host: 'foo.org') }

    context 'with :label' do
      subject { described_class.new(label: label) }

      it { is_expected.to respond_to(:label, :xlink).with(0).arguments }
      it { is_expected.not_to be_blank }

      it 'is expected to have the attributes correctly set' do
        expect(subject.label).to eql(label)
        expect(subject.xlink).to be_nil
      end
    end

    context 'with :xlink' do
      subject { described_class.new(xlink: xlink) }

      it { is_expected.to respond_to(:label, :xlink).with(0).arguments }
      it { is_expected.not_to be_blank }

      it 'is expected to have the attributes correctly set' do
        expect(subject.xlink).to eql(xlink)
        expect(subject.label).to be_nil
      end
    end

    context 'via .wrap_multiple' do
      subject { described_class.wrap_multiple(label: label, xlink: xlink) }

      it { is_expected.to be_an_instance_of(Array).and all(be_an_instance_of(described_class)) }

      # rubocop:disable Performance/Count
      it 'is expected to be non empty and have one xlink and one label element' do
        expect(subject.reject(&:blank?).count).to be(subject.count)
        expect(subject.select { |sub| sub.label == label }.count).to be(1)
        expect(subject.select { |sub| sub.xlink == xlink }.count).to be(1)
      end
      # rubocop:enable Performance/Count
    end
  end
end
