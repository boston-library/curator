# frozen_string_literal: true

module Curator
  class Mappings::NamePartModsPresenter
    attr_reader :label, :is_date

    def initialize(label, is_date = false)
      @label = label
      @is_date = is_date
    end

    def name_part_type
      is_date? ? 'date' : nil
    end

    def is_date?
      @is_date == true
    end
  end
end
