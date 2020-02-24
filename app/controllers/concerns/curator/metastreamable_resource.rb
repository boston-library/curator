# frozen_string_literal: true

module Curator
  module MetastreamableResource
    extend ActiveSupport::Concern
    included do
      prepend_before_action :set_metastreamable_resource
    end

    protected
    def set_metastreamable_resource
      @metastreamable_resource = metastreamable_scope.find_by(ark_id: params[:id]) || metastreamable_scope.find(params[:id])
    end

    def metastreamable_scope
      return @metastreamable_scope if defined?(@metastreamable_scope)

      @metastreamable_scope = "Curator::#{params[:metastreamable_type]}".constantize.with_metastreams
    rescue StandardError => e
      Rails.logger.error e.inspect
      raise Curator::Exceptions::BadRequest, "Bad parent metastream type #{params[:metastreamable_type]}"
    end
  end
end
