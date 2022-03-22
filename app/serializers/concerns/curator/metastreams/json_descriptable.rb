# frozen_string_literal: true

module Curator
  module Metastreams
    module JsonDescriptable
      extend ActiveSupport::Concern

      included do
        attributes :abstract, :digital_origin, :origin_event, :text_direction, :resource_type_manuscript, :place_of_publication, :publisher, :issuance, :frequency, :extent, :physical_location_department, :physical_location_shelf_locator, :series, :subseries, :subsubseries, :rights, :access_restrictions, :toc, :toc_url, :title, :note, :cartographic, :date, :related, :publication

        attribute :host_collections do |descriptable|
          descriptable.host_collections.names
        end

        one :physical_location do
          include Curator::ControlledTerms::JsonNomenclature
          include Curator::ControlledTerms::JsonName
        end

        one :license do
          include Curator::ControlledTerms::JsonNomenclature
          include Curator::ControlledTerms::JsonLicense
        end

        one :rights_statement do
          include Curator::ControlledTerms::JsonNomenclature
          include Curator::ControlledTerms::JsonRightsStatement
        end

        has_many :resource_types do
          include Curator::ControlledTerms::JsonNomenclature
          include Curator::ControlledTerms::JsonReso
        end

        has_many :genres do
          include Curator::ControlledTerms::JsonNomenclature
          include Curator::ControlledTerms::JsonGenre
        end

        many :identifier do
          attributes :label, :type, :invalid
        end

        many :note do
          attributes :label, :type
        end

        one :title do
          one :primary do
            attributes :label, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :authority_code, :id_from_auth, :part_name, :part_number
          end

          many :other do
            attributes :label, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :authority_code, :id_from_auth, :part_name, :part_number
          end
        end

        one :cartographic do
          attributes :scale, :projection
        end

        one :date do
          attributes :created, :issued, :copyright
        end
      end
    end
  end
end
