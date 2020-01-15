# frozen_string_literal: true

module Curator
  class DigitalObject < ApplicationRecord
    include Curator::Mintable
    include Curator::Metastreamable
    include Curator::Mappings::Exemplary::ObjectImagable
    include Curator::Indexable

    validates :contained_by_id, uniqueness: { scope: :ark_id }, unless: -> { contained_by.blank? }

    before_create :add_admin_set_to_members, if: -> { admin_set.present? } # Should Fail if admin set is not present

    belongs_to :admin_set, inverse_of: :admin_set_objects, class_name: 'Curator::Collection'
    belongs_to :contained_by, inverse_of: :contained_for, class_name: 'Curator::DigitalObject', optional: true

    has_one :institution, through: :admin_set, class_name: 'Curator::Institution'

    has_many :contained_for, inverse_of: :contained_by, class_name: 'Curator::DigitalObject'

    with_options inverse_of: :file_set_of, foreign_key: :file_set_of_id, dependent: :destroy do
      has_many :file_sets, class_name: 'Curator::Filestreams::FileSet'
      has_many :audio_file_sets, class_name: 'Curator::Filestreams::Audio'
      has_many :image_file_sets, class_name: 'Curator::Filestreams::Image'
      has_many :document_file_sets, class_name: 'Curator::Filestreams::Document'
      has_many :ereader_file_sets, class_name: 'Curator::Filestreams::Ereader'
      has_many :metadata_file_sets, class_name: 'Curator::Filestreams::Metadata'
      has_many :text_file_sets, class_name: 'Curator::Filestreams::Text'
      has_many :video_file_sets, class_name: 'Curator::Filestreams::Video'
    end

    has_many :collection_members, inverse_of: :digital_object, class_name: 'Curator::Mappings::CollectionMember', dependent: :destroy
    has_many :is_member_of_collection, through: :collection_members, source: :collection
    has_many :file_set_member_mappings, -> { includes(:file_set) }, inverse_of: :digital_object, class_name: 'Curator::Mappings::FileSetMember', dependent: :destroy

    with_options through: :file_set_member_mappings, source: :file_set do
      has_many :file_set_members, class_name: 'Curator::Filestreams::FileSet'
      has_many :audio_file_set_members, source_type: 'Curator::Filestreams::Audio'
      has_many :image_file_set_members, source_type: 'Curator::Filestreams::Image'
      has_many :document_file_set_members, source_type: 'Curator::Filestreams::Document'
      has_many :ereader_file_set_members, source_type: 'Curator::Filestreams::Ereader'
      has_many :metadata_file_set_members, source_type: 'Curator::Filestreams::Metadata'
      has_many :text_file_set_members, source_type: 'Curator::Filestreams::Text'
      has_many :video_file_set_members, source_type: 'Curator::Filestreams::Video'
    end


    self.curator_indexable_mapper = Curator::DigitalObjectIndexer.new

    private

    def add_admin_set_to_members
      collection_members.build(collection: admin_set)
    end
  end
end
