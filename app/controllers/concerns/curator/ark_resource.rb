# frozen_string_literal: true

module Curator
  module ArkResource
    extend ActiveSupport::Concern

    included do
      prepend_before_action :set_ark_id, only: [:show, :update]
    end

    protected

    def set_ark_id
      type = controller_path.dup.split('/').last&.to_sym
      if params.key?(:ark_id)
        @ark_id = params[:ark_id]
      elsif params.fetch(type, {}).key?(:ark_id)
        @ark_id = params.dig(type, :ark_id)
      end
    end
  end
end
