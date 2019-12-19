# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    # indexing for all subjects except geographic: topic, name, title, temporal, date
    module SubjectIndexer
      extend ActiveSupport::Concern

      included do
        configure do
          # topic subjects
          to_field %w(subject_topic_tsim subject_facet_ssim) do |record, accumulator|
            record.descriptive.subject_topics.each do |topic|
              accumulator << topic.label
            end if record.descriptive&.subject_topics
          end

          # name subjects
          to_field %w(subject_name_tsim subject_facet_ssim) do |record, accumulator|
            record.descriptive.subject_names.each do |name|
              accumulator << name.label
            end if record.descriptive&.subject_names
          end

          # title subjects
          to_field %w(subject_title_tsim subject_facet_ssim) do |record, accumulator|
            record.descriptive.subject_other.titles&.each do |title|
              accumulator << title.label
            end if record.descriptive&.subject_other
          end

          # temporal subjects
          to_field %w(subject_temporal_tsim subject_facet_ssim) do |record, accumulator|
            record.descriptive.subject_other.temporals&.each do |temporal|
              accumulator << temporal
            end if record.descriptive&.subject_other
          end

          # date subjects
          each_record do |record, context|
            next unless record.descriptive&.subject_other&.dates

            context.output_hash['subject_date_tsim'] = []
            subject_dates = []
            record.descriptive.subject_other.dates.each do |subject_date|
              subject_dates << subject_date
              subject_date_value = Curator::Parsers::EdtfDateParser.date_for_display(date: subject_date)
              context.output_hash['subject_date_tsim'] << subject_date_value
              context.output_hash['subject_facet_ssim'] << subject_date_value
            end
            subject_date_range = Curator::Parsers::EdtfDateParser.range_for_dates(subject_dates)
            context.output_hash['subject_date_start_dtsi'] = [subject_date_range[:start_date_for_index]]
            context.output_hash['subject_date_end_dtsi'] = [subject_date_range[:end_date_for_index]]
          end
        end
      end
    end
  end
end
