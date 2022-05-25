# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::DescriptiveFieldSets::TemporalSubjectModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:wrap_multiple).with(0..1).arguments }
  it { is_expected.to respond_to(:new).with(1).argument }

  it 'expects .wrap_multiple to return empty array by default' do
    expect(subject.wrap_multiple).to be_an_instance_of(Array).and be_empty
  end

  describe 'instance' do
    subject { described_class.new(temporal) }

    let!(:subject_obj) { create(:curator_descriptives_subject) }
    let!(:temporals) { subject_obj.temporals }
    let!(:dates) { subject_obj.dates }
    let!(:temporal) { subject_obj.temporals.first }

    it { is_expected.to respond_to(:temporal, :point, :encoding, :label, :date_temporal).with(0).arguments }

    it 'expects the instance to behave like the temporal is a String' do
      expect(subject.temporal).to be_an_instance_of(String)
      expect(subject.date_temporal).to be(nil)
      expect(subject.label).to equal(subject.temporal)
      expect(subject.encoding).to be(nil)
      expect(subject.point).to be(nil)
    end

    context 'with date temporal' do
      subject { described_class.new(date_presenter) }

      let!(:date_presenter) { Curator::DescriptiveFieldSets::DateModsPresenter.new(**parsed_date) }
      let!(:parsed_date) { parse_edtf_date(dates.first) }

      it { is_expected.to respond_to(:temporal, :point, :encoding, :label, :date_temporal).with(0).arguments }

      it 'expects certain methods to be delegated to date_temporal' do
        expect(subject).to delegate_method(:encoding).to(:date_temporal).allow_nil
        expect(subject).to delegate_method(:point).to(:date_temporal).allow_nil
      end

      it 'expects the instance to behave like the temporal is a Curator::DescriptiveFieldSets::DateModsPresenter' do
        expect(subject.temporal).to be_an_instance_of(Curator::DescriptiveFieldSets::DateModsPresenter)
        expect(subject.date_temporal).to be_truthy
        expect(subject.date_temporal.object_id).to eql(subject.temporal.object_id)
        expect(subject.label).to eql(subject.date_temporal.label)
        expect(subject.encoding).to be_an_instance_of(String)
      end
    end

    context 'with .wrap_multiple' do
      subject { described_class.wrap_multiple([temporal_string, temporal_date_presenter]) }

      it { is_expected.to be_an_instance_of(Array).and all(be_an_instance_of(described_class)) }

      let!(:temporal_string) { temporals.last }
      let!(:temporal_date_presenter) { Curator::DescriptiveFieldSets::DateModsPresenter.new(**parsed_date) }
      let!(:parsed_date) { parse_edtf_date(dates.last) }

      it 'expects there to be one of each kind of temporal' do
        expect(subject.map(&:temporal)).to include(an_instance_of(String)).at_most(:once)
        expect(subject.map(&:temporal)).to include(an_instance_of(Curator::DescriptiveFieldSets::DateModsPresenter)).at_most(:once)
        expect(subject.map(&:label)).to include(an_instance_of(String)).at_least(:twice)
        expect(subject.map(&:label)).to contain_exactly(temporal_string, temporal_date_presenter.label)
      end
    end
  end
end
