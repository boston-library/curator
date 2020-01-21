# frozen_string_literal: true

module Curator
  class Filestreams::FileSet < ApplicationRecord
    self.inheritance_column = :file_set_type

    include Curator::Mappings::Exemplary::FileSet
    include Curator::Mintable
    include Curator::Metastreams::Workflowable
    include Curator::Metastreams::Administratable
    include Curator::Indexable

    acts_as_list scope: [:file_set_of, :file_set_type], top_of_list: 0

    before_create :add_file_set_of_to_members, if: -> { file_set_of.present? }

    belongs_to :file_set_of, inverse_of: :file_sets, class_name: 'Curator::DigitalObject'

    has_many :file_set_member_of_mappings, -> { includes(:digital_object) }, inverse_of: :file_set, class_name: 'Curator::Mappings::FileSetMember', dependent: :destroy

    has_many :file_set_members_of, through: :file_set_member_of_mappings, source: :digital_object

    has_one_attached :metadata_foxml

    validates :file_name_base, presence: true
    validates :file_set_type, presence: true, inclusion: { in: Filestreams.file_set_types.collect { |type| "Curator::Filestreams::#{type}" } }

    self.curator_indexable_mapper = Curator::FileSetIndexer.new

    private

    def add_file_set_of_to_members
      file_set_member_of_mappings.build(digital_object: file_set_of)
    end
  end
end
