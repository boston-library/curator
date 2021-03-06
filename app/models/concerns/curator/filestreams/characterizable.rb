# frozen_string_literal: true

module Curator
  module Filestreams
    module Characterizable
      extend ActiveSupport::Concern
      included do
        has_one_attached :characterization, service: :derivatives
      end
    end
  end
end
