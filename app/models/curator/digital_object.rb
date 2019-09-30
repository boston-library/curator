# frozen_string_literal: true
module Curator
  class DigitalObject < ApplicationRecord
    include Curator::Mintable
    include Curator::Metastreamable

    before_create :add_admin_set_to_members, if: proc {|d| d.admin_set.present? } #Should Fail if admin set is not present

    belongs_to :admin_set, inverse_of: :admin_set_digital_objects, class_name: Curator.collection_class.to_s

    has_many :collection_members, inverse_of: :digital_object, class_name: Curator.mappings.collection_member_class.to_s

    has_many :file_sets, as: :file_set_of, inverse_of: :file_set_of, class_name: Curator.filestreams.file_set_class.to_s

    has_many :is_member_of_collection, through: :collection_members, source: :collection

    private
    def add_admin_set_to_members
      self.collection_members.build(collection: admin_set)
    end
  end
end
