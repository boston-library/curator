# frozen_string_literal: true

module PresenterHelpers
  module DateHelper
    def parse_edtf_date(date, inferred: false)
      date_hash = Curator::Parsers::EdtfDateParser.edtf_date_parser(date: date, inferred: inferred)
      date_hash = date_hash.dup.except(:type)

      return date_hash if date_hash[:start].blank? || date_hash[:end].blank?

      [date_hash.dup.except(:end), date_hash.dup.except(:start)]
    end
  end

  module RelatedHelper
    def related_type_lookup(type)
      return if !Curator::DescriptiveFieldSets::RELATED_TYPES.key?(type)

      Curator::DescriptiveFieldSets::RELATED_TYPES[type]
    end
  end

  module NameHelper
    # @returns [Array[Curator::Mappings::NamePartModsPresenter]]
    def map_name_parts(name = nil)
      return [] if name.blank?

      case name.name_type
      when 'corporate'
        Curator::Parsers::InputParser.corp_name_part_splitter(name.label).map { |np| Curator::Mappings::NamePartModsPresenter.new(np) }
      when 'personal'
        names_hash = Curator::Parsers::InputParser.pers_name_part_splitter(name.label)
        names_hash.reduce([]) do |ret, (key, val)|
          next ret if val.blank?

          is_date = key == :date_part
          ret << Curator::Mappings::NamePartModsPresenter.new(val, is_date)
          ret
        end
      else
        [Curator::Mappings::NamePartModsPresenter.new(name.label)]
      end
    end
  end
end


RSpec.configure do |config|
  config.include PresenterHelpers::DateHelper, type: :presenters
  config.include PresenterHelpers::RelatedHelper, type: :presenters
  config.include PresenterHelpers::NameHelper, type: :presenters
end
