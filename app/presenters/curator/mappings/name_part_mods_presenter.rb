# frozen_string_literal: true

module Curator
  class Mappings::NamePartModsPresenter
    # DESCRIPTION For serializing <mods:name><mods:namePart> elements
    # @param label [String]
    # @param[optional] is_date [Boolean]
    # @return [Curator::Mappings::RoleTermModsPresenter] instance
    attr_reader :label, :is_date

    def initialize(label, is_date = false)
      @label = label.to_s.encode('utf-8')
      @is_date = is_date
    end

    # @return [String | nil]
    def name_part_type
      is_date? ? 'date' : nil
    end

    # @return [Boolean]
    def is_date?
      @is_date == true
    end
  end
end
