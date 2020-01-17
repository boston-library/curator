# frozen_string_literal: true

module Curator
  module Mappings
    module MappedTerms
      extend ActiveSupport::Concern
      included do
        # Mapping objects
        has_many :desc_terms, inverse_of: :mapped_term, class_name: 'Curator::Mappings::DescTerm', foreign_key: :mapped_term_id, dependent: :destroy
      end
    end
  end
end
