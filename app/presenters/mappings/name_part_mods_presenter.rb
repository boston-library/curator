# frozen_string_literal: true

module Curator
  class Mappings::NamePartModsPresenter
    attr_reader :label, :is_date

    def initialize(label, is_date = false)
      @label = label
      @is_date = is_date
    end
  end
end
