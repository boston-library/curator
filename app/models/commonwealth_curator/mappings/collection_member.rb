# frozen_string_literal: true
module CommonwealthCurator
  class Mappings::CollectionMember < ApplicationRecord
    belongs_to :collection, inverse_of: :collection_members, class_name: 'CommonwealthCurator::Collection'
    belongs_to :digital_object, inverse_of: :is_member_of_collection, class_name: 'CommonwealthCurator::DigitalObject'
  end
end
