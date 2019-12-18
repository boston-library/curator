# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module SubjectIndexer
      extend ActiveSupport::Concern
      include Curator::Indexer::DateIndexerBehavior

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
            record.descriptive.subject_json['subject_other']&.titles&.each do |title|
              accumulator << title.label
            end if record.descriptive&.subject_json
          end

          # temporal subjects
          to_field %w(subject_temporal_tsim subject_facet_ssim) do |record, accumulator|
            record.descriptive.subject_json['subject_other']&.temporals&.each do |temporal|
              accumulator << temporal
            end if record.descriptive&.subject_json
          end

          # date subjects
          each_record do |record, context|
            next unless record.descriptive&.subject_json

            subject_dates = record.descriptive.subject_json['subject_other']&.dates
            next if subject_dates.empty?

            context.output_hash['subject_date_tsim'] = []
            parsed_date_subjects = []
            subject_dates.each do |subject_date|
              parsed_date_subject_hash = edtf_date_parser(subject_date)
              parsed_date_subjects << parsed_date_subject_hash
              subject_date_value = date_for_display(parsed_date_subject_hash)
              context.output_hash['subject_date_tsim'] << subject_date_value
              context.output_hash['subject_facet_ssim'] << subject_date_value
            end
            subject_date_range = range_for_parsed_dates(parsed_date_subjects)
            context.output_hash['subject_date_start_dtsi'] = [subject_date_range[:start_date_for_index]]
            context.output_hash['subject_date_end_dtsi'] = [subject_date_range[:end_date_for_index]]
          end
        end
      end
    end
  end
end
