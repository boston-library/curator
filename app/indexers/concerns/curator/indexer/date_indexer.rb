# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module DateIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          each_record do |record, context|
            next unless record.descriptive&.date

            date_fields = %w(date_start_tsim date_end_tsim date_facet_yearly_itim date_type_ssm
                             date_start_qualifier_ssm date_edtf_ssm)
            date_fields.each do |field|
              context.output_hash[field] ||= []
            end

            dates_static = []
            dates_start = []
            dates_end = []

            # iterate over date values, send them to #edtf_date_parser
            # we use "nil" as String to represent empty values (can't assign nil/null in Solr)
            mods_date_accessors = { created: 'dateCreated', issued: 'dateIssued', copyright: 'copyrightDate' }
            mods_date_accessors.each do |k, v|
              next unless record.descriptive.date.send(k)

              context.output_hash['date_type_ssm'] << v
              edtf_date = record.descriptive.date.send(k)
              context.output_hash['date_edtf_ssm'] << edtf_date
              parsed_date = edtf_date_parser(edtf_date)
              dates_static << parsed_date[:static] if parsed_date[:static]
              if parsed_date[:start] || parsed_date[:end]
                dates_start << parsed_date[:start]
                dates_end << parsed_date[:end]
              end
              context.output_hash['date_start_qualifier_ssm'] << (parsed_date[:qualifier] || 'nil')
            end

            # push the parsed date values as-is into text fields for display
            dates_static.each do |static_date|
              context.output_hash['date_start_tsim'] << static_date
              context.output_hash['date_end_tsim'] << 'nil'
            end
            dates_start.each_with_index do |start_date, index|
              context.output_hash['date_start_tsim'] << (start_date || 'unknown')
              context.output_hash['date_end_tsim'] << (dates_end[index] || 'open')
            end

            # set the date ranges for date-time fields and yearly faceting
            sorted_start_dates = (dates_static + dates_start.compact).sort
            earliest_date = sorted_start_dates.first
            date_facet_start = earliest_date[0..3].to_i
            latest_date = dates_end.compact.sort.reverse.first

            # set earliest date (date_start_dtsi)
            start_date_suffix = 'T00:00:00.000Z'
            if earliest_date.match?(/[0-9]{4}[0-9-]*\z/) # rough date format matching
              start_date_for_index = if earliest_date.length == 4
                                       "#{earliest_date}-01-01#{start_date_suffix}"
                                     elsif earliest_date.length == 7
                                       "#{earliest_date}-01#{start_date_suffix}"
                                     elsif earliest_date.length > 11
                                       earliest_date
                                     else
                                       "#{earliest_date}#{start_date_suffix}"
                                     end
              context.output_hash['date_start_dtsi'] = [start_date_for_index]
            end

            # set latest date (date_end_dtsi)
            end_date_suffix = 'T23:59:59.999Z'
            if latest_date&.match?(/[0-9]{4}[0-9-]*\z/)
              date_facet_end = latest_date[0..3].to_i
              end_date_for_index = if latest_date.length == 4
                                     "#{latest_date}-12-31#{end_date_suffix}"
                                   elsif latest_date.length == 7
                                     "#{latest_date}-#{last_day_of_month(latest_date)}#{end_date_suffix}"
                                   elsif latest_date.length > 11
                                     latest_date
                                   else
                                     "#{latest_date}#{end_date_suffix}"
                                   end
              context.output_hash['date_end_dtsi'] = [end_date_for_index]
            else
              date_facet_end = 0
              latest_start_date = sorted_start_dates.last
              if latest_start_date.match?(/[0-9]{4}[0-9-]*\z/)
                end_date_for_index = if latest_start_date.length == 4
                                       "#{latest_start_date}-12-31#{end_date_suffix}"
                                     elsif latest_start_date.length == 7
                                       "#{latest_start_date}-#{last_day_of_month(latest_start_date)}#{end_date_suffix}"
                                     elsif latest_start_date.length > 11
                                       latest_start_date
                                     else
                                       "#{latest_start_date}#{end_date_suffix}"
                                     end
                context.output_hash['date_end_dtsi'] = [end_date_for_index]
              end
            end

            # yearly faceting, starting with year 0 AD
            (0..(Time.current.year + 2)).step(1) do |index|
              if (date_facet_start >= index && date_facet_start < index + 1) ||
                 (date_facet_end != -1 && index > date_facet_start && date_facet_end >= index)
                context.output_hash['date_facet_yearly_itim'] << index
              end
            end
          end
        end
      end

      private

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
      def remove_edtf_qualifier(edtf_date_string)
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
    end
  end
end
