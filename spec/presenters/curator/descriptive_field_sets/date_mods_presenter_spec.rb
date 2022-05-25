# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::DescriptiveFieldSets::DateModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new).with_keywords(:key_date, :static, :start, :end, :qualifier) }

  describe 'instance' do
    subject { described_class.new(**parsed_date) }

    let!(:date_obj) { create(:curator_descriptives_date) }
    let!(:date) { date_obj.issued }
    let!(:parsed_date) { parse_edtf_date(date) }
    let!(:default_encoding) { Curator::Parsers::Constants::DATE_ENCODING }

    it { is_expected.to respond_to(:key_date, :static, :start, :end_date, :qualifier, :label, :point, :encoding).with(0).arguments }
    it { is_expected.not_to be_blank }

    it 'expects the instance to store the correct values' do
      expect(subject.key_date).to be(nil)
      expect(subject.static).to eql(date)
      expect(subject.start).to be(nil)
      expect(subject.end_date).to be(nil)
      expect(subject.qualifier).to be(nil)
    end

    it 'expects the instance methods to return the correct values' do
      expect(subject.label).to eql(date)
      expect(subject.encoding).to eql(default_encoding)
      expect(subject.point).to be(nil)
    end

    context 'with inferred date range' do
      subject do
        [
          described_class.new(key_date: true, **parsed_dates.first),
          described_class.new(**parsed_dates.last)
        ]
      end

      let!(:date_range) { date_obj.created }
      let!(:parsed_dates) { parse_edtf_date(date_range, inferred: true) }

      it 'expects the start element to store the correct values' do
        expect(subject[0].key_date).to eql('yes')
        expect(subject[0].static).to be(nil)
        expect(subject[0].start).to eql(parsed_dates[0][:start])
        expect(subject[0].end_date).to be(nil)
        expect(subject[0].qualifier).to eql('inferred')
      end

      it 'expects the end element to store the correct values' do
        expect(subject[1].key_date).to be(nil)
        expect(subject[1].static).to be(nil)
        expect(subject[1].start).to be(nil)
        expect(subject[1].end_date).to eql(parsed_dates[1][:end])
        expect(subject[1].qualifier).to eql('inferred')
      end

      it 'expects the instance methods for the start element to return the correct values' do
        expect(subject[0].encoding).to eql(default_encoding)
        expect(subject[0].point).to eql('start')
        expect(subject[0].label).to eql(subject[0].start)
      end

      it 'expects the instance methods for the end element to return the correct values' do
        expect(subject[1].encoding).to eql(default_encoding)
        expect(subject[1].point).to eql('end')
        expect(subject[1].label).to eql(subject[1].end_date)
      end
    end
  end
end
