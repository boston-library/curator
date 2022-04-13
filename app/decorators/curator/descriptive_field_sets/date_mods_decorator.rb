# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::DateModsDecorator < Decorators::BaseDecorator
    DATE_ENCODING='w3cdtf'

    # inferred = record.descriptive&.note&.map(&:label)&.any? { |nv| nv.include?('date is inferred') }
    # Curator::Parsers::EdtfDateParser#edtf_date_parser
  end
end
