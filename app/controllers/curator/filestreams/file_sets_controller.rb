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
      success, result = Curator::Filestreams::FileSetFactoryService.call(json_data: file_set_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :created)
    end

    def update
      success, result = Curator::Filestreams::FileSetUpdaterService.call(@curator_resource, json_data: file_set_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :ok)
    end

    private

    def file_set_params
      case params[:action]
      when 'create'
        params.require(:file_set).permit(:ark_id, :created_at, :updated_at,
                                         :file_set_type, :file_name_base, :position,
                                         file_set_of: [:ark_id],
                                          exemplary_image_of: [:ark_id],
                                          pagination: [:page_label, :page_type, :hand_side],
                                          metastreams: {
                                            administrative: [:description_standard, :hosting_status, :harvestable,
                                                             :flagged, destination_site: [], access_edit_group: []],
                                             workflow: [:ingest_origin, :publishing_state, :processing_state]
                                          },
                                         files: [:key, :created_at, :file_name, :file_type, :content_type, :byte_size,
                                                  :checksum_md5, io: {}, metadata: {}])
      when 'update'
        params.require(:file_set).permit(:position, pagination: [:page_label, :page_type, :hand_side],
                                         exemplary_image_of: [:ark_id, :_destroy],
                                         files: [:key, :file_name, :file_type, :content_type, :byte_size, :checksum_md5, io: {}, metadata: {}])
      else
        params
      end
    rescue StandardError => e
      Rails.logger.error "===========#{e.inspect}================"
      raise Curator::Exceptions::BadRequest, 'Invalid value for for type params', "#{controller_path.dup}/params/:type"
    end
  end
end
