# frozen_string_literal: true

module Curator
  class Metastreams::SubjectNameModsPresenter
    attr_reader :name, :name_parts

    delegate :authority_code, :authority_base_url, :value_uri, :name_type, to: :name, allow_nil: true

    def initialize(name, name_parts = [])
      @name = name
      @name_parts = name_parts
    end

    def blank?
      @name.blank? && @name_parts.blank?
    end
  end
end
