# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module DateIndexer
      extend ActiveSupport::Concern

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
              inferred = record.descriptive&.note&.map(&:label)&.any? { |nv| nv.include?('date is inferred') }
              context.output_hash['date_edtf_ssm'] << edtf_date
              context.output_hash['date_tsim'] << Curator::Parsers::EdtfDateParser.date_for_display(date: edtf_date,
                                                                                                    type: v,
                                                                                                    inferred: inferred)
              parsed_dates << edtf_date
            end

            # get the date ranges for date-time fields and yearly faceting
            date_range = Curator::Parsers::EdtfDateParser.range_for_dates(parsed_dates)
            context.output_hash['date_start_dtsi'] = [date_range[:start_date_for_index]]
            context.output_hash['date_end_dtsi'] = [date_range[:end_date_for_index]]

            # yearly faceting
            # item must have a start date, can't facet from start of time
            (date_range[:date_facet_start]..(date_range[:date_facet_end] || (Time.current.year + 2))).step(1) do |index|
              context.output_hash['date_facet_yearly_itim'] << index
            end if date_range[:date_facet_start]
          end
        end
      end
    end
  end
end
