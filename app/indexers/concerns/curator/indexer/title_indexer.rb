# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module TitleIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          # primary title fields
          to_field 'title_info_primary_tsi', obj_extract('descriptive', 'title', 'primary', 'label')
          to_field 'title_info_primary_ssort' do |record, accumulator|
            accumulator << Curator::Parsers::InputParser.get_proper_title(
              record.descriptive.title&.primary&.label
            ).last
          end
          to_field 'title_info_partnum_tsi', obj_extract('descriptive', 'title', 'primary', 'part_number')
          to_field 'title_info_partname_tsi', obj_extract('descriptive', 'title', 'primary', 'part_name')
          to_field 'title_info_primary_subtitle_tsi', obj_extract('descriptive', 'title', 'primary', 'subtitle')
          # other title fields
          each_record do |record, context|
            multival_title_fields = %w(title_info_primary_trans_tsim title_info_translated_tsim
                                       title_info_alternative_tsim title_info_uniform_tsim title_info_uniform_ssim
                                       title_info_alternative_label_ssm title_info_other_subtitle_tsim)
            multival_title_fields.each { |field| context.output_hash[field] ||= [] }
            record.descriptive.title&.other&.each do |other_title|
              title_field = if other_title.type == 'translated'
                              other_title.usage == 'primary' ? ['title_info_primary_trans_tsim'] : ['title_info_translated_tsim']
                            elsif other_title.type == 'alternative' || other_title.type == 'abbreviated'
                              ['title_info_alternative_tsim']
                            elsif other_title.type == 'uniform'
                              %w(title_info_uniform_tsim title_info_uniform_ssim)
                            else
                              raise "WEIRD TITLE TYPE (#{other_title.type}) FOUND FOR DIGITAL OBJECT #{record.ark_id}"
                            end
              title_field.each { |t| context.output_hash[t] << other_title.label }
              context.output_hash['title_info_alternative_label_ssm'] << other_title.display
              context.output_hash['title_info_other_subtitle_tsim'] << other_title.subtitle
            end
          end
        end
      end
    end
  end
end
