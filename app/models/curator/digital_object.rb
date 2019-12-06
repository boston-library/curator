# frozen_string_literal: true

module Curator
  class DigitalObject < ApplicationRecord
    include Curator::Mintable
    include Curator::Metastreamable
    include Curator::Mappings::Exemplary::ObjectImagable
    include Curator::Indexable

    before_create :add_admin_set_to_members, if: proc { |d| d.admin_set.present? } # Should Fail if admin set is not present

    belongs_to :admin_set, inverse_of: :admin_set_objects, class_name: 'Curator::Collection'
    has_one :institution, through: :admin_set, class_name: 'Curator::Institution'

    with_options inverse_of: :file_set_of, foreign_key: :file_set_of_id, dependent: :destroy do
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

    with_options class_name: 'Curator::Mappings::Issue', dependent: :destroy do
      has_one :issue_mapping, -> { includes(:issue_of) }, inverse_of: :digital_object
      has_one :issue_mapping_for, -> { includes(:digital_object) }, inverse_of: :issue_of, foreign_key: :issue_of_id
    end

    with_options class_name: 'Curator::DigitalObject' do
      has_one :issue_of, through: :issue_mapping, source: :issue_of
      has_one :issue_for, through: :issue_mapping_for, source: :digital_object
    end

    self.curator_indexable_mapper = Curator::DigitalObjectIndexer.new

    private

    def add_admin_set_to_members
      collection_members.build(collection: admin_set)
    end
  end
end
