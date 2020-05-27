# frozen_string_literal: true

module Curator
  class DigitalObjectsController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    # GET /digital_objects
    def index
      digital_objects = resource_scope.order(created_at: :desc).limit(25)
      multi_response(serialized_resource(digital_objects))
    end

    # GET /digital_objects/1
    def show
      multi_response(serialized_resource(@curator_resource))
    end

    # POST /digital_objects
    def create
      success, result = Curator::DigitalObjectFactoryService.call(json_data: digital_object_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :created)
    end

    # PATCH/PUT /digital_objects/1
    def update
      success, result = Curator::DigitalObjectUpdaterService.call(@curator_resource, json_data: digital_object_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :ok)
    end

    private

    def digital_object_params
      case params[:action]
      when 'create'
        params.require(:digital_object).permit(:ark_id, :created_at, :updated_at,
                                               admin_set: [:ark_id],
                                               is_member_of_collection: [:ark_id],
                                               contained_by: [:ark_id],
                                               metastreams: {
                                                 descriptive: [:abstract,
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
                                                             ],
                                                               administrative: [:description_standard, :hosting_status, :harvestable, :flagged, destination_site: [], access_edit_group: []],
                                                               workflow: [:ingest_origin, :publishing_state, :processing_state]
                                               })
      when 'update'
        # NOTE: for collection_members to remove pass in the :id of the mapping object and :_destroy = 1/true to remove and just :ark_id for the collection to add see #should_add_collection_member?/ #should_remove_collection_member? in /services/digital_object_updater_service.rb
        params.require(:digital_object).permit(is_member_of_collection: [:ark_id, :_destroy], exemplary_file_set: [:ark_id])
      else
        params
      end
    end
  end
end
