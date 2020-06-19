# frozen_string_literal: true

module Curator
  class FieldSets::Publication < FieldSets::Base
    attr_json :edition_name, :string
    attr_json :edition_number, :string
    attr_json :volume, :string
    attr_json :issue_number, :string
  end
end
