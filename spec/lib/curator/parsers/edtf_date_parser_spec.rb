# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Parsers::EdtfDateParser do
  describe '#date_for_display' do
    it 'returns the formatted human-readable date' do
      expect(described_class.date_for_display(date: '1925-12-01?')).to eq '[December 1, 1925?]'
      expect(described_class.date_for_display(date: '1925~/1930~')).to eq '[ca. 1925–1930]'
      expect(described_class.date_for_display(date: '1925/..')).to eq '1925–'
      expect(described_class.date_for_display(date: '/1925')).to eq '–1925'
      expect(described_class.date_for_display(date: '1925', type: 'copyrightDate')).to eq '(c) 1925'
      expect(described_class.date_for_display(date: '-1925')).to eq '1925 B.C.E.'
      expect(described_class.date_for_display(date: '-605~/-562~')).to eq '[ca. 605 B.C.E.–562 B.C.E.]'
      expect(described_class.date_for_display(date: '-8000/1500')).to eq '8000 B.C.E.–1500 C.E.'
      expect(described_class.date_for_display(date: '1925', type: 'dateCreated', inferred: true)).to eq '[1925]'
    end
  end

  describe '#range_for_dates' do
    it 'returns a hash with date ranges for indexing and faceting' do
      expect(described_class.range_for_dates(%w(1924 1925/1930))).to eq(
        { start_date_for_index: '1924-01-01T00:00:00.000Z', end_date_for_index: '1930-12-31T23:59:59.999Z',
          date_facet_start: 1924, date_facet_end: 1930 }
      )
      expect(described_class.range_for_dates(['/2017'])).to eq(
        { start_date_for_index: nil, end_date_for_index: '2017-12-31T23:59:59.999Z',
          date_facet_start: nil, date_facet_end: 2017 }
      )
      expect(described_class.range_for_dates(['2017-12/..'])).to eq(
        { start_date_for_index: '2017-12-01T00:00:00.000Z', end_date_for_index: nil,
          date_facet_start: 2017, date_facet_end: nil }
      )
      expect(described_class.range_for_dates(['2017-11'])).to eq(
        { start_date_for_index: '2017-11-01T00:00:00.000Z', end_date_for_index: '2017-11-30T23:59:59.999Z',
          date_facet_start: 2017, date_facet_end: 2017 }
      )
      expect(described_class.range_for_dates(['-605/-562'])).to eq(
         { start_date_for_index: '-0605-01-01T00:00:00.000Z', end_date_for_index: '-0562-12-31T23:59:59.999Z',
           date_facet_start: -605, date_facet_end: -562 }
       )
    end
  end

  describe '#edtf_date_parser' do
    it 'parses EDTF date strings' do
      expect(described_class.edtf_date_parser(date: '1925~')).to eq(
        { static: '1925', start: nil, end: nil, qualifier: 'approximate', type: nil }
      )
      expect(described_class.edtf_date_parser(date: '1925?/1930?', type: 'dateCreated')).to eq(
        { static: nil, start: '1925', end: '1930', qualifier: 'questionable', type: 'dateCreated' }
      )
      expect(described_class.edtf_date_parser(date: '/1930-12')).to eq(
        { static: nil, start: nil, end: '1930-12', qualifier: nil, type: nil }
      )
      expect(described_class.edtf_date_parser(date: '1925-12-01/..')).to eq(
        { static: nil, start: '1925-12-01', end: nil, qualifier: nil, type: nil }
      )
      expect(described_class.edtf_date_parser(date: '-2350')).to eq(
        { static: '-2350', start: nil, end: nil, qualifier: nil, type: nil }
      )
      expect(described_class.edtf_date_parser(date: '1925', type: nil, inferred: true)).to eq(
        { static: '1925', start: nil, end: nil, qualifier: 'inferred', type: nil }
      )
    end
  end
end
