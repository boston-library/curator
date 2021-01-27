# frozen_string_literal: true

module Curator
  class Mappings::HostCollection < ApplicationRecord
    belongs_to :institution, inverse_of: :host_collections, class_name: 'Curator::Institution'

    validates :name, presence: true, uniqueness: { scope: :institution_id }

    has_many :desc_host_collections, inverse_of: :host_collection,
             class_name: 'Curator::Mappings::DescHostCollection', dependent: :destroy

    scope :name_lower, ->(name) { where('lower(name) = ?', name.downcase) }

    after_update_commit :reindex_descriptable_objects

    has_paper_trail

    private

    def reindex_descriptable_objects
      desc_host_collections.find_each do |desc_host_col|
        desc_host_col.descriptive.descriptable.update_index
      end
    end
  end
end
