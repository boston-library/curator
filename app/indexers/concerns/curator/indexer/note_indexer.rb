# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module NoteIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          each_record do |record, context|
            note_fields = %w(arrangement resp performers acquisition ownership citation reference venue
                             physical date language funding biographical publication credits)
            note_fields.each { |field| context.output_hash["note_#{field}_tsim"] ||= [] }
            context.output_hash['note_tsim'] ||= []
            record.descriptive.note.each do |note|
              label = note.label
              note_type = note.type
              note_field = case note_type
                           when 'biographical/historical'
                             'biographical'
                           when 'citation/reference'
                             'reference'
                           when 'preferred citation'
                             'citation'
                           when 'creation/production credits'
                             'credits'
                           when 'physical-description'
                             'physical'
                           when 'statement of responsibility'
                             'resp'
                           else
                             note_type
                           end
              if note_type
                context.output_hash["note_#{note_field}_tsim"] << label
              else
                context.output_hash['note_tsim'] << label
              end
            end
          end
        end
      end
    end
  end
end
