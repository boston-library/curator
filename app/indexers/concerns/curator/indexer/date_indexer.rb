# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module DateIndexer
      extend ActiveSupport::Concern
      include Curator::Indexer::DateIndexerBehavior

      included do
        configure do
          each_record do |record, context|
            next unless record.descriptive&.date

            date_fields = %w(date_tsim date_facet_yearly_itim date_type_ssm date_edtf_ssm)
            date_fields.each do |field|
              context.output_hash[field] ||= []
            end

            # iterate over date values, send them to #edtf_date_parser, add them to parsed_dates
            parsed_dates = []
            mods_date_accessors = { created: 'dateCreated', issued: 'dateIssued', copyright: 'copyrightDate' }
            mods_date_accessors.each do |k, v|
              next unless record.descriptive.date.send(k)

              context.output_hash['date_type_ssm'] << v
              edtf_date = record.descriptive.date.send(k)
              context.output_hash['date_edtf_ssm'] << edtf_date
              parsed_date_hash = edtf_date_parser(edtf_date)
              parsed_date_hash[:date_type] = v
              context.output_hash['date_tsim'] << date_for_display(parsed_date_hash)
              parsed_dates << parsed_date_hash
            end

            # get the date ranges for date-time fields and yearly faceting
            date_range = range_for_parsed_dates(parsed_dates)
            context.output_hash['date_start_dtsi'] = [date_range[:start_date_for_index]]
            context.output_hash['date_end_dtsi'] = [date_range[:end_date_for_index]]

            # yearly faceting, starting with year 0 AD
            date_facet_start = date_range[:date_facet_start]
            date_facet_end = date_range[:date_facet_end]
            if date_facet_start && date_facet_end
              (0..(Time.current.year + 2)).step(1) do |index|
                if (date_facet_start >= index && date_facet_start < index + 1) ||
                    (date_facet_end != -1 && index > date_facet_start && date_facet_end >= index)
                  context.output_hash['date_facet_yearly_itim'] << index
                end
              end
            end
          end
        end
      end
    end
  end
end
