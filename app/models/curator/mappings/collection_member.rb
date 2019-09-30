# frozen_string_literal: true
module Curator
  class Mappings::CollectionMember < ApplicationRecord
    belongs_to :collection, inverse_of: :collection_members, class_name: Curator.collection_class.to_s
    belongs_to :digital_object, inverse_of: :is_member_of_collection, class_name: Curator.digital_object_class.to_s
  end
end
