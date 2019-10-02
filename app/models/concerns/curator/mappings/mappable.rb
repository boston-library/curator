# frozen_string_literal: true
module Curator
  module Mappings
    module Mappable
      extend ActiveSupport::Concern
      included do
        #Mapping objects
        has_many :desc_terms, as: :mappable, inverse_of: :mappable, class_name: Curator.mappings.desc_term_class_name
      end
    end
  end
end
