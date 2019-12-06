# frozen_string_literal: true

module Curator
  class Filestreams::FileSet < ApplicationRecord
    self.inheritance_column = :file_set_type

    include Curator::Mintable
    include Curator::Metastreams::Workflowable
    include Curator::Metastreams::Administratable
    include Curator::Indexable

    has_one_attached :metadata_foxml

    validates :file_name_base, presence: true
    validates :file_set_type, presence: true, inclusion: { in: Filestreams.file_set_types.collect { |type| "Curator::Filestreams::#{type}" } }

    self.curator_indexable_mapper = Curator::FileSetIndexer.new
  end
end
