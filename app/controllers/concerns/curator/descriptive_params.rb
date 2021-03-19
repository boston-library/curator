# frozen_string_literal: true

module Curator
  module DescriptiveParams
    extend ActiveSupport::Concern

    included do
      include ParamsPermitHelpers
    end

    module ParamsPermitHelpers
      private

      REMOVABLE_TERMS = [:genres, :languages, :name_roles, :resource_types].freeze

      REMOVABLE_SUBJECT_TERMS = [:topics, :names, :geos].freeze

      PERMITTED_PARAMS = [
        :abstract,
        :access_restrictions,
        :digital_origin,
        :extent,
        :frequency,
        :issuance,
        :origin_event,
        :physical_location_department,
        :physical_location_shelf_locator,
        :place_of_publication,
        :publisher,
        :resource_type_manuscript,
        :rights,
        :series,
        :subseries,
        :subsubseries,
        :text_direction,
        :toc,
        :toc_url,
        cartographic: [:projection, scale: []],
        date: [:created, :issued, :copyright],
        host_collections: [],
        identifier: [:label, :type, :invalid],
        genres: [:label, :id_from_auth, :authority_code, :basic],
        languages: [:label, :id_from_auth, :authority_code],
        license: [:label, :uri],
        name_roles: [name: [:label, :name_type, :authority_code, :id_from_auth, :affiliation], role: [:label, :id_from_auth, :authority_code]],
        note: [:label, :type],
        physical_location: [:authority_code, :id_from_auth, :label, :affiliation, :name_type],
        publication: [:edition_name, :edition_number, :volume, :issue_number],
        related: [:constituent, referenced_by: [:label, :url], references_url: [], other_format: [], review_url: []],
        resource_types: [:label, :authority_code, :id_from_auth],
        rights_statement: [:label, :uri],
        subject: [topics: [:label, :authority_code, :id_from_auth], names: [:label, :name_type, :authority_code, :id_from_auth, :affiliation], geos: [:label, :authority_code, :id_from_auth, :coordinates, :bounding_box, :area_type], titles: [:label, :id_from_auth, :subtitle, :authority_code, :display, :display_label, :usage, :supplied, :language, :type, :part_number, :part_name], temporals: [], dates: []],
        title: [primary: [:label, :id_from_auth, :authority_code, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :part_number, :part_name], other: [:label, :id_from_auth, :subtitle, :authority_code, :display, :display_label, :usage, :supplied, :language, :type, :part_number, :part_name]]
      ].freeze

      def descriptive_permitted_params(operation = 'create')
        case operation
        when 'create'
          return PERMITTED_PARAMS.dup
        when 'update'
          return PERMITTED_PARAMS.dup.inject([]) do |ret, param|
            ret << param if param.is_a?(Symbol)

            ret << add_destroy_attrs(param.dup) if param.is_a?(Hash)

            ret
          end
        else
          return []
        end
      end

      def add_destroy_attrs(nested_permits = {})
        REMOVABLE_TERMS.each do |key|
          nested_permits[key] = nested_permits[key].unshift(:_destroy)
        end

        REMOVABLE_SUBJECT_TERMS.each do |sub_key|
          nested_permits[:subject][0][sub_key] = nested_permits[:subject][0][sub_key].unshift(:_destroy)
        end

        nested_permits
      end
    end
  end
end
