# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    # common functions for parsing and indexing dates
    module DateIndexerBehavior
      ##
      # TODO: deal with inferred dates
      # takes an EDTF-formatted date string and returns a hash of MODS-y date values
      # we support "/1945" (unknown start) and "1945/.." (open end)
      # @param edtf_date_string [String]
      # @return [Hash] { static: '', start: '', end: '', qualifier: '' }
      def edtf_date_parser(edtf_date_string)
        date_hash = { static: nil, start: nil, end: nil, qualifier: nil }
        range = edtf_date_string.match?(/\//) ? true : false
        split_range = edtf_date_string.split('/')
        date_hash[:qualifier] = 'questionable' if split_range[0].match?(/\?/)
        date_hash[:qualifier] = 'approximate' if split_range[0].match?(/~/)
        if range
          date_hash[:start] = remove_edtf_qualifier(split_range[0])
          date_hash[:end] = remove_edtf_qualifier(split_range[1])
        else
          date_hash[:static] = remove_edtf_qualifier(split_range[0])
        end
        date_hash
      end

      ##
      # remove EDTF qualifiers from date values: %w(? ~ ..)
      # @param edtf_date_string [String]
      # @return [String]
      def remove_edtf_qualifier(edtf_date_string)
        return nil unless edtf_date_string
        edtf_date_string.gsub(/(\?|~|\.\.)/, '')
      end

      ##
      # return the last day for the given year and month
      # @param year_plus_month [String] YYYY-MM
      # @return [String] last day as two digits
      def last_day_of_month(year_plus_month)
        split_date = year_plus_month.split('-')
        Date.new(split_date[0].to_i, split_date[1].to_i).end_of_month.day.to_s
      end

      ##
      # takes a parsed date hash and returns a string for display
      # @param parsed_date_hash [Hash] { static: '', start: '', end: '', qualifier: '', type: '' }
      # @return [String] date formatted for display
      def date_for_display(parsed_date_hash)
        prefix, suffix, date_start_suffix = '', '', ''
        if parsed_date_hash[:qualifier]
          prefix = parsed_date_hash[:qualifier] == 'approximate' ? '[ca. ' : '['
          suffix = parsed_date_hash[:qualifier] == 'questionable' ? '?]' : ']'
        end
        prefix = '(c) ' if parsed_date_hash[:date_type] == 'copyrightDate'
        if parsed_date_hash[:start] || parsed_date_hash[:end]
          date_start_suffix = '?' if parsed_date_hash[:qualifier] == 'questionable'
          date_value = normalize_date(parsed_date_hash[:start]) + date_start_suffix + '–' + normalize_date(parsed_date_hash[:end])
        else
          date_value = normalize_date(parsed_date_hash[:static])
        end
        prefix + date_value + suffix
      end

      ##
      # @param date_string [String] 2011-02-28
      # @return [String] human readable date: February 28, 2011
      def normalize_date(date_string)
        return '' unless date_string
        case date_string.length
        when 10
          Date.parse(date_string).strftime('%B %-d, %Y')
        when 7
          Date.parse(date_string + '-01').strftime('%B %Y')
        else
          date_string
        end
      end

      ##
      # @param parsed_dates [Array]
      # @return [Hash] earliest and latest dates for indexing, faceting, etc.
      def range_for_parsed_dates(parsed_dates)
        dates_start, dates_end = [], []
        date_facet_start = nil
        parsed_dates.each do |parsed_date|
          dates_start << (parsed_date[:start] || parsed_date[:static])
          dates_end << parsed_date[:end] if parsed_date[:end]
        end
        sorted_start_dates = dates_start.compact.sort
        earliest_date = sorted_start_dates.first
        date_facet_start = earliest_date[0..3].to_i if earliest_date
        latest_date = dates_end.compact.sort.reverse.first
        start_date_for_index = solr_dtsi_date(date: earliest_date, type: 'start')
        date_facet_end = latest_date&.match?(/[0-9]{4}[0-9-]*\z/) ? latest_date[0..3].to_i : 0
        end_date_for_index = solr_dtsi_date(date: latest_date, type: 'end')

        { start_date_for_index: start_date_for_index, end_date_for_index: end_date_for_index,
          date_facet_start: date_facet_start, date_facet_end: date_facet_end }
      end

      ##
      # @param date [String] a w3cdtf date
      # @param type [String] 'start' or 'end'
      # @return [String] formatted date for Solr dtsi field
      def solr_dtsi_date(date: '', type: '')
        return nil unless date&.match?(/[0-9]{4}[0-9-]*\z/)
        if type == 'start'
          suffix = 'T00:00:00.000Z'
          month = '01'
          day = '01'
        else
          suffix = 'T23:59:59.999Z'
          month = '12'
          day = date.length == 7 ? last_day_of_month(date) : '31'
        end
        if date.length == 4
          "#{date}-#{month}-#{day}#{suffix}"
        elsif date.length == 7
          "#{date}-#{day}#{suffix}"
        elsif date.length > 11
          date
        else
          "#{date}#{suffix}"
        end
      end
    end
  end
end
