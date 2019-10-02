# frozen_string_literal: true
module Curator
  class DigitalObject < ApplicationRecord
    include Curator::Mintable
    include Curator::Metastreamable

    before_create :add_admin_set_to_members, if: proc {|d| d.admin_set.present? } #Should Fail if admin set is not present

    belongs_to :admin_set, inverse_of: :admin_set_objects, class_name: Curator.collection_class_name

    with_options inverse_of: :file_set_of, foreign_key: :file_set_of_id do
      has_many :audio_file_sets, class_name: Curator.filestreams.audio_class_name
      has_many :image_file_sets, class_name: Curator.filestreams.image_class_name
      has_many :document_file_sets, class_name: Curator.filestreams.document_class_name
      has_many :ereader_file_sets, class_name: Curator.filestreams.ereader_class_name
      has_many :metadata_file_sets, class_name: Curator.filestreams.metadata_class_name
      has_many :text_file_sets, class_name: Curator.filestreams.text_class_name
      has_many :video_file_sets, class_name: Curator.filestreams.video_class_name
    end

    has_many :collection_members, inverse_of: :digital_object, class_name: Curator.mappings.collection_member_class_name
    has_many :is_member_of_collection, through: :collection_members, source: :collection

    private
    def add_admin_set_to_members
      self.collection_members.build(collection: admin_set)
    end
  end
end
