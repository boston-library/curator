# frozen_string_literal: true
module CommonwealthCurator
  class Collection < ApplicationRecord
    include CommonwealthCurator::Mintable
    include CommonwealthCurator::Metastreamable
    include CommonwealthCurator::Mappings::ExemplaryImagable

    belongs_to :institution, inverse_of: :collections, class_name: CommonwealthCurator.collection_class.to_s

    has_many :admin_set_digital_objects, inverse_of: :admin_set, class_name: CommonwealthCurator.digital_object_class.to_s, foreign_key: :admin_set_id

    has_many :collection_members, inverse_of: :collection, class_name: CommonwealthCurator.mappings.collection_member_class.to_s

  end
end
