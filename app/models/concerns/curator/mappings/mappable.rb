# frozen_string_literal: true

module Curator
  module Mappings
    module Mappable
      extend ActiveSupport::Concern
      included do
        # Mapping objects
        has_many :desc_terms, ->(s) { rewhere(mappable_type: s.class.to_s) }, as: :mappable, inverse_of: :mappable, class_name: Curator.mappings.desc_term_class_name
      end
    end
  end
end
