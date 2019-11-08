# frozen_string_literal: true

module Curator
  module Parsers
    # move useful data parsing methods from Bplmodels::DatastreamInputFuncs here
    class InputParser
      ##
      # @param [String] full title
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
    end
  end
end
