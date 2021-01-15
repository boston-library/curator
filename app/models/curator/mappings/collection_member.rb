# frozen_string_literal: true

module Curator
  class Mappings::CollectionMember < ApplicationRecord
    belongs_to :collection, inverse_of: :collection_members, class_name: 'Curator::Collection'
    belongs_to :digital_object, inverse_of: :is_member_of_collection, class_name: 'Curator::DigitalObject'

    validates :collection_id, uniqueness: { scope: :digital_object_id }

    has_paper_trail
  end
end
