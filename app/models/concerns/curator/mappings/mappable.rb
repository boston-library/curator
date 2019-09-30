# frozen_string_literal: true
module Curator
  module Mappings
    module Mappable
      extend ActiveSupport::Concern
      included do
        has_many :descriptive_terms, as: :mappable, inverse_of: :mappable, class_name: Curator.mappings.desc_term_class.to_s
      end
    end
  end
end
