# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::DateModsPresenter
    attr_reader :start, :end_date, :static, :qualifier, :key_date

    def initialize(key_date: false, static: nil, start: nil, end: nil, qualifier: nil)
      @static = static
      @start = start
      @end_date = binding.local_variable_get(:end)
      @qualifier = qualifier
      @key_date = key_date == true ? 'yes' : nil
    end

    def label
      static.presence || start.presence || end_date.presence
    end

    def blank?
      static.blank? && start.blank? && end_date.blank?
    end

    def encoding
      Curator::Parsers::EdtfDateParser::DATE_ENCODING
    end

    def point
      return if start.blank? && @end.blank?

      return 'start' if start.present? && end_date.blank?

      'end'
    end
  end
end
