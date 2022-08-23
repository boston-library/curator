# frozen_string_literal: true

module Curator
  module Parsers
    # move useful data parsing methods from Bplmodels::DatastreamInputFuncs here
    class InputParser
      ##
      # @param title [String] full title
      # @return [Array] [mods:nonSort leading article (with spaces), remaining title]
      def self.get_proper_title(title)
        return [] if title.blank?

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
      # @return [Hash] used to populate <mods:namePart> and <mads:namePart type="date"> where <mods:name type="personal">
      def self.pers_name_part_splitter(input_string)
        name_part_hash = { name_part: nil, date_part: nil }

        return name_part_hash if input_string.blank?

        return name_part_hash.merge(name_part: input_string) if input_string !~ /\d{4}/ || input_string =~ /\(.*\d{4}.*\)/

        split_array = input_string.split(/.*,/)
        name_part_hash[:name_part] = input_string.gsub(/,[\d\- \.\w?]*$/, '')
        name_part_hash[:date_part] = split_array[1].strip if split_array[1].present?
        name_part_hash
      end

      ##
      # @param value [String] raw input
      # @return [Array] used to populate <mods:namePart> subparts where <mods:name type="corporate">
      def self.corp_name_part_splitter(input_string)
        return [] if input_string.blank?

        return [input_string] if !input_string.match?(Curator::Parsers::Constants::CORP_NAME_INPUT_MATCHER)

        name_parts_array = []
        in_str = input_string.dup

        # Changed to use #match? rater than =~ since it retuns true/false rather than Integer/nil
        while in_str.match?(Curator::Parsers::Constants::CORP_NAME_INPUT_MATCHER)
          snip = Curator::Parsers::Constants::CORP_NAME_INPUT_MATCHER.match(in_str).post_match
          sub_part = in_str.gsub(snip, '')
          name_parts_array << sub_part.gsub(/\.\z/, '').strip
          in_str = snip
        end
        # Add the last part of the in_str(with rmoved periods and stripped whitespace) if it isn't already present in the name_parts_array
        # Added this due to corporate names like "United States. Work Projects Administration" only returning [United States]
        # This last part was missing from the original bplmodels code https://github.com/boston-library/bplmodels/blob/e780be71db82b8b39278973ff9015cc7df7208a9/lib/bplmodels/datastream_input_funcs.rb#L42
        final_name_part = in_str.gsub(/\.\z/, '').strip
        name_parts_array << final_name_part if final_name_part.present? && name_parts_array.exclude?(final_name_part)
        name_parts_array
      end

      ##
      # @param value [String] raw input
      # @return [String] UTF-8 encoded, no HTML tags, no line breaks, etc.
      def self.utf8_encode(value)
        return '' if value.blank?

        value = value.force_encoding('UTF-8')
        value = value.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '') unless value.valid_encoding?
        HTMLEntities.new.decode(ActionView::Base.full_sanitizer.sanitize(value.gsub(/<br[\s]*\/>/, ' '))).gsub("\\'", "'").squish
      end

      ##
      # @param value [String] raw input
      # @return [String] UTF-8 encoded, no HTML tags, no line breaks, etc.
      def self.strip_value(value)
        return if value.blank?

        case value
        when Float, Integer
          value = value.to_i.to_s
        end

        utf8_encode(value)
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
