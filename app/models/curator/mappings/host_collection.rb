# frozen_string_literal: true

module Curator
  class Mappings::HostCollection < ApplicationRecord
    belongs_to :institution, inverse_of: :host_collections, class_name: 'Curator::Institution'

    validates :name, presence: true, uniqueness: { scope: :institution_id }

    has_many :desc_host_collections, inverse_of: :host_collection, class_name: 'Curator::Mappings::DescHostCollection', dependent: :destroy
  end
end
