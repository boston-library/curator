module Curator
  class Mappings::FileSetMember < ApplicationRecord
    belongs_to :digital_object, inverse_of: :file_set_member_mappings, class_name: 'Curator::DigitalObject'
    belongs_to :file_set, inverse_of: :file_set_member_of_mappings, class_name: 'Curator::Filestreams::FileSet'

    validates :digital_object_id, uniqueness: { scope: :file_set_id }, on: :create
  end
end
