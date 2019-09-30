# frozen_string_literal: true
module Curator
  class ControlledTerms::License < ControlledTerms::Nomenclature
    include Mappings::Mappable
    belongs_to :authority, class_name: 'Curator::ControlledTerms::Authority', optional: true
    #NOTE These dont really have authorities but this line is required so rails doesnt try to validate this relatonship
    #ALSO I did not specify an inverse_of on eiher relationship so these should be hidden from authorities

    attr_json :uri, :string

    validates :label, presence: true
    validates :uri, format: { with: URI::regexp(%w(http https)), allow_nil: true }
  end
end
