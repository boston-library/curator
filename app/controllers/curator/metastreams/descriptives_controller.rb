# frozen_string_literal: true

module Curator
  class Metastreams::DescriptivesController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    before_action :set_descriptive, only: [:show, :update]

    def show
      json_response(serialized_resource(@descriptive))
    end

    def update
      success, result = Metastreams::DescriptiveUpdaterService.call(@descriptive, json_data: descriptive_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :ok)
    end

    private

    def set_descriptive
      @descriptive = @curator_resource.descriptive
    end

    def descriptive_params
      case params[:action]
      when 'update'
        params.require(:descriptive).permit(:abstract,
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
                                            related: [:constituent, referenced_by_url: [], references_url: [], other_format: [], review_url: []],
                                            resource_types: [:label, :authority_code, :id_from_auth],
                                            subject: [topics: [:label, :authority_code, :id_from_auth], names: [:label, :name_type, :authority_code, :id_from_auth, :affiliation], geos: [:label, :authority_code, :id_from_auth, :coordinates, :bounding_box, :area_type], titles: [:label, :id_from_auth, :subtitle, :authority_code, :display, :display_label, :usage, :supplied, :language, :type, :part_number, :part_name], temporals: [], dates: []],
                                            title: [primary: [:label, :id_from_auth, :authority_code, :subtitle, :display, :display_label, :usage, :supplied, :language, :type, :part_number, :part_name], other: [:label, :id_from_auth, :subtitle, :authority_code, :display, :display_label, :usage, :supplied, :language, :type, :part_number, :part_name]]
                                           )
      else
        params
      end
    end
  end
end
