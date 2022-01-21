# frozen_string_literal: true

module Curator
  module Parsers
    # methods for working with EDTF dates, serializing for Solr, MODS XML, etc
    class EdtfDateParser
      ##
      # @param date [String] EDTF date
      # @param type [String] the type of MODS date (dateCreated, dateIssued, etc.)
      # @param inferred [Boolean]
      # @return [String] date formatted for display
      def self.date_for_display(date: '', type: nil, inferred: false)
        prefix, suffix, date_start_suffix = '', '', ''
        edtf_date_hash = edtf_date_parser(date: date, type: type, inferred: inferred)
        if edtf_date_hash[:qualifier]
          prefix = edtf_date_hash[:qualifier] == 'approximate' ? '[ca. ' : '['
          suffix = edtf_date_hash[:qualifier] == 'questionable' ? '?]' : ']'
        end
        prefix = '(c) ' if edtf_date_hash[:type] == 'copyrightDate'
        if edtf_date_hash[:start] || edtf_date_hash[:end]
          date_start_suffix = '?' if edtf_date_hash[:qualifier] == 'questionable'
          date_value = "#{normalize_date(edtf_date_hash[:start])}#{date_start_suffix}–#{normalize_date(edtf_date_hash[:end])}"
        else
          date_value = normalize_date(edtf_date_hash[:static])
        end
        prefix + date_value + suffix
      end

      ##
      # @param edtf_dates [Array] of EDTF date strings
      # @return [Hash] earliest and latest dates for indexing, faceting, etc.
      def self.range_for_dates(edtf_dates)
        dates_start, dates_end = [], []
        date_facet_start = nil
        edtf_dates.each do |edtf_date|
          edtf_date_hash = edtf_date_parser(date: edtf_date)
          dates_start << (edtf_date_hash[:start] || edtf_date_hash[:static])
          dates_end << (edtf_date_hash[:end] || edtf_date_hash[:static])
        end
        sorted_start_dates = dates_start.compact.sort
        earliest_date = sorted_start_dates.first
        date_facet_start = earliest_date.match(/\A-?\d*/).string.to_i if earliest_date
        latest_date = dates_end.compact.sort.reverse.first
        start_date_for_index = solr_dtsi_date(date: earliest_date, type: 'start')
        date_facet_end = latest_date&.match?(/\A-?\d*/) ? latest_date.match(/\A-?\d*/).string.to_i : nil
        end_date_for_index = solr_dtsi_date(date: latest_date, type: 'end')

        { start_date_for_index: start_date_for_index, end_date_for_index: end_date_for_index,
          date_facet_start: date_facet_start, date_facet_end: date_facet_end }
      end

      ##
      # takes an EDTF-formatted date string and returns a hash of MODS-y date values
      # we support "/1945" (unknown start) and "1945/.." (open end)
      # @param date [String] EDTF date
      # @param type [String] the type of MODS date (dateCreated, dateIssued, etc.)
      # @param inferred [Boolean]
      # @return [Hash] { static: , start: , end: , qualifier: , type: }
      def self.edtf_date_parser(date: '', type: nil, inferred: false)
        date_hash = { static: nil, start: nil, end: nil, qualifier: nil, type: type }
        range = date.match?(/\//) ? true : false
        split_range = date.split('/')
        date_hash[:qualifier] = if split_range[0].match?(/\?/)
                                  'questionable'
                                elsif split_range[0].match?(/~/)
                                  'approximate'
                                elsif inferred
                                  'inferred'
                                end
        if range
          date_hash[:start] = remove_edtf_qualifier(split_range[0]).presence
          date_hash[:end] = remove_edtf_qualifier(split_range[1]).presence
        else
          date_hash[:static] = remove_edtf_qualifier(split_range[0])
        end
        date_hash
      end

      ##
      # remove EDTF qualifiers from date values: %w(? ~ ..)
      # @param edtf_date_string [String]
      # @return [String]
      def self.remove_edtf_qualifier(edtf_date_string)
        return nil unless edtf_date_string

        edtf_date_string.gsub(/(\?|~|\.\.)/, '')
      end

      ##
      # return the last day for the given year and month
      # @param year_plus_month [String] YYYY-MM
      # @return [String] last day as two digits
      def self.last_day_of_month(year_plus_month)
        split_date = year_plus_month.split('-')
        Date.new(split_date[0].to_i, split_date[1].to_i).end_of_month.day.to_s
      end

      ##
      # @param date_string [String] 2011-02-28
      # @return [String] human readable date: February 28, 2011
      def self.normalize_date(date_string)
        return '' unless date_string

        date_string = case date_string.length
                      when 10
                        Date.parse(date_string).strftime('%B %-d, %Y')
                      when 7
                        Date.parse(date_string + '-01').strftime('%B %Y')
                      else
                        date_string
                      end
        return date_string unless date_string.match?(/\A-\d/) # deal with BC dates ("-2350")

        "#{date_string[1..-1]} B.C."
      end

      ##
      # @param date [String] a w3cdtf date
      # @param type [String] 'start' or 'end'
      # @return [String] formatted date for Solr dtsi field
      def self.solr_dtsi_date(date: '', type: '')
        return nil unless date&.match?(/\A-?\d/)

        prefix = ''
        if date.match?(/\A-\d/) # deal with BC dates ("-2350")
          date = date[1..-1]
          0.upto(4) { |i| date.prepend('0') if date.length < i }
          prefix = '-'
        end
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
          "#{prefix}#{date}-#{month}-#{day}#{suffix}"
        elsif date.length == 7
          "#{prefix}#{date}-#{day}#{suffix}"
        elsif date.length > 11
          "#{prefix}#{date}"
        else
          "#{prefix}#{date}#{suffix}"
        end
      end

      private_class_method :remove_edtf_qualifier, :last_day_of_month, :normalize_date, :solr_dtsi_date
    end
  end
end
