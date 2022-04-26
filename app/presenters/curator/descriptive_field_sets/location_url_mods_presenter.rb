# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::LocationUrlModsPresenter
    attr_reader :url, :usage, :access, :note

    def initialize(url, usage: nil, access: nil, note: nil)
      @url = url
      @usage = usage
      @access = access
      @note = note
    end
  end
end
