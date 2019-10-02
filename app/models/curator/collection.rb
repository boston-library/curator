# frozen_string_literal: true
module Curator
  class Collection < ApplicationRecord
    include Curator::Mintable
    include Curator::Metastreamable
    include Curator::Mappings::ExemplaryImagable

    belongs_to :institution, inverse_of: :collections, class_name: Curator.institution_class_name

    has_many :admin_set_objects, inverse_of: :admin_set, class_name: Curator.digital_object_class_name, foreign_key: :admin_set_id

    has_many :collection_members, inverse_of: :collection, class_name: Curator.mappings.collection_member_class_name

  end
end
