# frozen_string_literal: true

module Curator
  class ControlledTerms::License < ControlledTerms::AccessCondition
    has_many :licensees, inverse_of: :license, class_name: 'Curator::Metastreams::Descriptive',
             foreign_key: :license_id, dependent: :destroy

    validates :uri, format: { with: URI.regexp(%w(http https)), allow_blank: true }
  end
end
