# frozen_string_literal: true

module Curator
  class ControlledTerms::RightsStatement < ControlledTerms::AccessCondition
    has_many :rights_statement_of, inverse_of: :rights_statement, class_name: 'Curator::Metastreams::Descriptive',
             foreign_key: :rights_statement_id, dependent: :destroy

    validates :uri, presence: true, format: { with: URI.regexp(%w(http https)) }
  end
end
