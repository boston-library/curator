# frozen_string_literal: true

module Curator
  module Georeferenceable
    extend ActiveSupport::Concern

    def georeferenceable?
      image_file_sets.present? && descriptive.resource_types.map(&:label).include?('Cartographic')
    end

    # NOTE: this method will be deprecated once the transition to Allmaps is complete
    def georeferenced?
      return false unless georeferenceable?

      ActiveStorage::Attachment.where(name: 'image_georectified_primary', record_type: 'Curator::Filestreams::FileSet', record_id: image_file_sets.pluck(:id)).limit(1).exists?
    end

    def georeferenced_in_allmaps?
      return false unless georeferenceable?

      allmaps_annotation = Curator::AllmapsAnnotationsService.call("#{ark_uri}/manifest")
      allmaps_annotation.present?
    end
  end
end
