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
          include Curator::ControlledTerms::JsonName
        end

        one :license do
          include Curator::ControlledTerms::JsonLicense
        end

        one :rights_statement do
          include Curator::ControlledTerms::JsonRightsStatement
        end

        has_many :resource_types do
          include Curator::ControlledTerms::JsonReso
        end

        has_many :genres do
          include Curator::ControlledTerms::JsonGenre
        end

        has_many :languages do
          include Curator::ControlledTerms::JsonLanguage
        end

        many :identifier do
          attributes :label, :type, :invalid
        end

        many :note do
          attributes :label, :type
        end

        one :title do
          one :primary do
            include Curator::DescriptiveFieldSets::JsonTitle
          end

          many :other do
            include Curator::DescriptiveFieldSets::JsonTitle
          end
        end

        one :cartographic do
          attributes :scale, :projection
        end

        one :date do
          attributes :created, :issued, :copyright
        end

        one :related do
          attributes :constituent, :other_format, :references_url, :review_url

          many :referenced_by do
            attributes :label, :url
          end
        end

        one :publication do
          attributes :edition_name, :edition_number, :volume, :issue_number
        end

        has_many :name_roles do
          one :name do
            include Curator::ControlledTerms::JsonName
          end

          one :role do
            include Curator::ControlledTerms::JsonRole
          end
        end

        one :subject do
          attributes :dates, :temporals
          many :topics do
            include Curator::ControlledTerms::JsonSubject
          end
        end
      end
    end
  end
end
