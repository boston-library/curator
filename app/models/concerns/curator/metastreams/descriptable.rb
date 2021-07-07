# frozen_string_literal: true

module Curator
  module Metastreams
    module Descriptable
      extend ActiveSupport::Concern
      included do
        scope :with_descriptive, -> { includes(descriptive: [{ physical_location: :authority }, { name_roles: [:name, :role] }, :license, :rights_statement, :genres, :resource_types, :languages, :subject_topics, :subject_names, :subject_geos, :host_collections]) }

        has_one :descriptive, inverse_of: :digital_object, class_name: 'Curator::Metastreams::Descriptive', dependent: :destroy, autosave: true

        validates :descriptive, presence: true
        validates_associated :descriptive, on: :create
      end
    end
  end
end
