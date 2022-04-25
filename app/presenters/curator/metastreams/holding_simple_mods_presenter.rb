# frozen_string_literal: true

module Curator
  class Metastreams::HoldingSimpleModsPresenter
    CopyInformation = Struct.new(:sub_location, :shelf_locator, keyword_init: true)

    attr_reader :copy_information

    def initialize(sub_location: nil, shelf_locator: nil)
      @copy_information = CopyInformation.new(sub_location: sub_location, shelf_locator: shelf_locator)
    end

    def blank?
      copy_information.sub_location.blank? && copy_information.shelf_locator.blank?
    end
  end
end
