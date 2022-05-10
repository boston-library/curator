# frozen_string_literal: true

module Curator
  module Parsers
    # move useful data parsing methods from Bplmodels::DatastreamInputFuncs here
    class InputParser
      ##
      # @param title [String] full title
      # @return [Array] [mods:nonSort leading article (with spaces), remaining title]
      def self.get_proper_title(title)
        non_sort = nil
        title_array = title.split(' ')
        spec_char_regex = /\A[\S]{1,2}['-]/
        string_to_eval = if title_array[0].match?(spec_char_regex)
                           title_array[0].match(spec_char_regex)[0]
                         else
                           title_array[0]
                         end
        non_sort = string_to_eval if Curator::Parsers::Constants::NONSORT_ARTICLES.include?(string_to_eval.downcase)
        title_minus_sort = title.sub(/#{non_sort}/, '')
        non_sort += ' ' if title_minus_sort.first.match?(/\A\s/)
        [non_sort, title_minus_sort.lstrip]
      end

      ##
      # @param value [String] raw input
      # @return [String] UTF-8 encoded, no HTML tags, no line breaks, etc.
      def self.utf8_encode(value)
        value = value.force_encoding('UTF-8')
        value = value.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '') unless value.valid_encoding?
        HTMLEntities.new.decode(ActionView::Base.full_sanitizer.sanitize(value.gsub(/<br[\s]*\/>/, ' '))).gsub("\\'", "'").squish
      end

      ##
      # wrapper for chaining steps related to 'cleaning' text prior to indexing
      # @param value [String] raw input
      # @return [String]
      def self.clean_text(value)
        value = Curator::Parsers::InputParser.utf8_encode(value)
        # remove Zooniverse transcription markup
        value.gsub(/\[\/?(deletion|insertion|table|unclear|underline)\]/, '').squish
      end
    end
  end
end
