# frozen_string_literal: true

module Curator
  class Filestreams::FileSet < ApplicationRecord
    self.inheritance_column = :file_set_type

    VALID_HAND_SIDES = %w(right left).freeze

    include AttrJson::Record
    include AttrJson::Record::QueryScopes
    include AttrJson::Record::Dirty
    include Curator::Filestreams::Characterizable
    include Curator::Filestreams::MetadataFoxable
    include Curator::Mappings::Exemplary::FileSet
    include Curator::Mintable
    include Curator::Metastreamable::Basic
    include Curator::Indexable

    # TODO: Add this scope to :for_serialization once we start attaching files in the FileSetFactoryService
    # def self.with_all_attachments
    #   reflections.keys.select { |ref| ref =~ /_attachment/ }
    #   includes(attachment_reflections)
    # end

    self.curator_indexable_mapper = Curator::FileSetIndexer.new

    scope :for_serialization, -> { merge(with_metastreams) }

    attr_json_config(default_container_attribute: :pagination)

    attr_json :page_label, :string
    attr_json :page_type, :string
    attr_json :hand_side, :string

    validates :hand_side, inclusion: { in: VALID_HAND_SIDES, allow_nil: true }

    acts_as_list scope: [:file_set_of, :file_set_type], top_of_list: 0

    before_create :add_file_set_of_to_members, if: -> { file_set_of.present? }

    belongs_to :file_set_of, inverse_of: :file_sets, class_name: 'Curator::DigitalObject'

    has_many :file_set_member_of_mappings, -> { includes(:digital_object) }, inverse_of: :file_set, class_name: 'Curator::Mappings::FileSetMember', dependent: :destroy

    has_many :file_set_members_of, through: :file_set_member_of_mappings, source: :digital_object

    validates :file_name_base, presence: true
    validates :file_set_type, presence: true, inclusion: { in: Filestreams.file_set_types.collect { |type| "Curator::Filestreams::#{type}" } }

    after_commit :reindex_digital_objects

    private

    def add_file_set_of_to_members
      file_set_member_of_mappings.build(digital_object: file_set_of)
    end

    def reindex_digital_objects
      file_set_members_of.find_each { |digital_object| digital_object.update_index }
    end
  end
end
