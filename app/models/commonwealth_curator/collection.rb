# frozen_string_literal: true
module CommonwealthCurator
  class Collection < ApplicationRecord
    include CommonwealthCurator::Mintable
    include CommonwealthCurator::Mappings::ExemplaryImagable
    include CommonwealthCurator::Metastreamable

    belongs_to :institution, inverse_of: :collections, class_name: 'CommonwealthCurator::Institution'

    has_many :admin_set_digital_objects, inverse_of: :admin_set, class_name: 'CommonwealthCurator::DigitalObject', foreign_key: :admin_set_id

    has_many :collection_members, inverse_of: :collection, class_name: 'CommonwealthCurator::Mappings::CollectionMember'
    
  end
end
