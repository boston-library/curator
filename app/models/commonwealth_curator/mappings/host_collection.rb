# frozen_string_literal: true
module CommonwealthCurator
  class Mappings::HostCollection < ApplicationRecord
    belongs_to :institution, inverse_of: :host_collections, class_name: 'CommonwealthCurator::Institution'

    validates :name, presence: true, uniqueness: {scope: :institution_id, allow_nil: true }

    has_many :desc_host_collections, inverse_of: :host_collection, class_name: 'CommonwealthCurator::Mappings::DescHostCollection' 
  end
end
