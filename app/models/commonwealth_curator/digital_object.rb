# frozen_string_literal: true
module CommonwealthCurator
  class DigitalObject < ApplicationRecord
    include CommonwealthCurator::Mintable
    include CommonwealthCurator::Metastreamable

    before_create: :add_admin_set_to_members, if: proc{|do| do.admin_set.present? } #Should Fail if admin set is not present

    belongs_to :admin_set, inverse_of: :admin_set_digital_objects, class_name: 'CommonwealthCurator::Collection'

    has_many :collection_members, inverse_of: :digital_object, class_name: 'CommonwealthCurator::Mappings::CollectionMember'

    has_many :file_sets, as: :file_set_of, inverse_of: :file_set_of, class_name: 'CommonwealthCurator::Filestreams::FileSet', -> { order(position: :asc) }

    has_many :is_member_of_collection, through: :collection_members, source: :collection

    private
    def add_admin_set_to_members
      self.collection_members.build(collection: admin_set)
    end
  end
end
