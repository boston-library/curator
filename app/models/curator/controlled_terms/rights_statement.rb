# frozen_string_literal: true

# see ControlledTerms::License for further explanation of modeling
module Curator
  class ControlledTerms::RightsStatement < ControlledTerms::Nomenclature
    include ControlledTerms::ReindexDescriptable
    undef_method :desc_terms
    belongs_to :authority, class_name: 'Curator::ControlledTerms::Authority', optional: true

    has_many :rights_statement_of, inverse_of: :rights_statement, class_name: 'Curator::Metastreams::Descriptive',
             foreign_key: :rights_statement_id, dependent: :destroy

    attr_json :uri, :string

    validates :label, presence: true
    validates :uri, format: { with: URI.regexp(%w(http https)), presence: true }
  end
end
