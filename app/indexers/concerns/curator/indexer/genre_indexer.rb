# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module GenreIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          each_record do |record, context|
            next unless record.descriptive&.genres

            %w(genre_basic_tim genre_basic_ssim genre_specific_tim genre_specific_ssim).each do |field|
              context.output_hash[field] ||= []
            end
            record.descriptive.genres.find_each do |genre|
              label = genre.label
              if genre.basic
                %w(genre_basic_tim genre_basic_ssim).each do |basic_field|
                  context.output_hash[basic_field] << label
                end
              else
                %w(genre_specific_tim genre_specific_ssim).each do |specific_field|
                  context.output_hash[specific_field] << label
                end
              end
            end
          end
        end
      end
    end
  end
end
