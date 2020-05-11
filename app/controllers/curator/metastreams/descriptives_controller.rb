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
      @descriptive.touch
      json_response(serialized_resource(@descriptive))
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
                                            :toc_url
                                          )
      else
        params
      end
    end
  end
end
