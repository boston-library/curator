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

  module NameHelper
    def name_parts(name)
    end
  end
end


RSpec.configure do |config|
  config.include PresenterHelpers::DateHelper, type: :presenters
end
