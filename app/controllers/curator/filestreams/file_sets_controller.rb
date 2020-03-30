# frozen_string_literal: true

module Curator
  class Filestreams::FileSetsController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    def index
      file_sets = resource_scope.order(created_at: :desc).limit(25)
      multi_response(serialized_resource(file_sets))
    end

    def show
      multi_response(serialized_resource(@curator_resource))
    end

    def create
      success, file_set = Curator::FileSetFactoryService.call(file_set_params)

      raise_failure(result) unless success

      json_response(serialized_resource(file_set), :created)
    end

    def update
      @curator_resource.touch
      json_response(serialized_resource(@curator_resource))
    end

    private

    def file_set_params
      # NOTE: Should we only whitelist the master files on create?
      case params[:action]
      when 'create'
        case params.fetch(:file_set).fetch(:file_set_type)
        when 'audio'
          params.require(:file_set).permit(:ark_id, :created_at, :updated_at,
                                            :file_set_type, :file_name_base, :position,
                                            file_set_of: [:ark_id],
                                            exemplary_image_of: [:ark_id],
                                            pagination: [:page_label, :page_type, :hand_side],
                                            metastreams: {
                                              administrative: [:description_standard, :hosting_status, :harvestable, :flagged, destination_site: [], access_edit_group: []],
                                               workflow: [:ingest_origin, :publishing_state, :processing_state]
                                            },
                                            metadata_foxml: {},
                                            audio_master: {},
                                            document_master: {}
                                           )
        when 'document'
          params.require(:file_set).permit(:ark_id, :created_at, :updated_at,
                                            :file_set_type, :file_name_base, :position,
                                            file_set_of: [:ark_id],
                                            exemplary_image_of: [:ark_id],
                                            pagination: [:page_label, :page_type, :hand_side],
                                            metastreams: {
                                              administrative: [:description_standard, :hosting_status, :harvestable, :flagged, destination_site: [], access_edit_group: []],
                                               workflow: [:ingest_origin, :publishing_state, :processing_state]
                                            },
                                            metadata_foxml: {},
                                            document_master: {}
                                           )
        when 'ereader'
          params.require(:file_set).permit(:ark_id, :created_at, :updated_at,
                                            :file_set_type, :file_name_base, :position,
                                            file_set_of: [:ark_id],
                                            exemplary_image_of: [:ark_id],
                                            pagination: [:page_label, :page_type, :hand_side],
                                            metastreams: {
                                              administrative: [:description_standard, :hosting_status, :harvestable, :flagged, destination_site: [], access_edit_group: []],
                                               workflow: [:ingest_origin, :publishing_state, :processing_state]
                                            },
                                            metadata_foxml: {},
                                            ebook_access: {}
                                           )
        when 'image'
          params.require(:file_set).permit(:ark_id, :created_at, :updated_at,
                                            :file_set_type, :file_name_base, :position,
                                            file_set_of: [:ark_id],
                                            exemplary_image_of: [:ark_id],
                                            pagination: [:page_label, :page_type, :hand_side],
                                            metastreams: {
                                              administrative: [:description_standard, :hosting_status, :harvestable, :flagged, destination_site: [], access_edit_group: []],
                                               workflow: [:ingest_origin, :publishing_state, :processing_state]
                                            },
                                            metadata_foxml: {},
                                            image_negative_master: {},
                                            image_master: {},
                                            image_georectified_master: {}
                                           )
        when 'metadata'
          params.require(:file_set).permit(:ark_id, :created_at, :updated_at,
                                            :file_set_type, :file_name_base, :position,
                                            file_set_of: [:ark_id],
                                            exemplary_image_of: [:ark_id],
                                            pagination: [:page_label, :page_type, :hand_side],
                                            metastreams: {
                                              administrative: [:description_standard, :hosting_status, :harvestable, :flagged, destination_site: [], access_edit_group: []],
                                               workflow: [:ingest_origin, :publishing_state, :processing_state]
                                            })
        when 'text'
          params.require(:file_set).permit(:ark_id, :created_at, :updated_at,
                                            :file_set_type, :file_name_base, :position,
                                            file_set_of: [:ark_id],
                                            exemplary_image_of: [:ark_id],
                                            pagination: [:page_label, :page_type, :hand_side],
                                            metastreams: {
                                              administrative: [:description_standard, :hosting_status, :harvestable, :flagged, destination_site: [], access_edit_group: []],
                                               workflow: [:ingest_origin, :publishing_state, :processing_state]
                                            })
        when 'video'
          params.require(:file_set).permit(:ark_id, :created_at, :updated_at,
                                            :file_set_type, :file_name_base, :position,
                                            file_set_of: [:ark_id],
                                            exemplary_image_of: [:ark_id],
                                            pagination: [:page_label, :page_type, :hand_side],
                                            metastreams: {
                                              administrative: [:description_standard, :hosting_status, :harvestable, :flagged, destination_site: [], access_edit_group: []],
                                               workflow: [:ingest_origin, :publishing_state, :processing_state]
                                            })
        else
          raise Curator::Exceptions::UnknownResourceType, 'Unspecified :file_set_type params!'
        end
      else
        params
      end
    rescue StandardError => e
      Rails.logger.error "===========#{e.inspect}================"
      raise Curator::Exceptions::BadRequest, 'Invalid value for for type params', "#{controller_path.dup}/params/:type"
    end
  end
end
