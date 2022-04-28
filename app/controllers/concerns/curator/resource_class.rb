# frozen_string_literal: true

module Curator
  module ResourceClass
    extend ActiveSupport::Concern
    def resource_scope
      return resource_class.with_metastreams if resource_for_metastream?

      return resource_class if params[:action] == 'update'

      return resource_class.for_serialization if resource_class.respond_to?(:for_serialization)

      resource_class
    end

    def serialized_resource(resource, serializer_params = {})
      serializer_class.new(resource, serializer_params, adapter_key: @serializer_adapter_key || :json).serialize
    rescue StandardError => e
      Rails.logger.error "=======#{e.inspect}======"
      raise Curator::Exceptions::ServerError, "Failed to render serialized resource as #{@serializer_adapter_key}"
    end

    protected

    def serializer_class
      return @serializer_class if defined?(@serializer_class)

      @serializer_class = define_serializer_class
    end

    def resource_class
      return @resource_class if defined?(@resource_class)

      @resource_class = define_resource_class
    end

    def resource_type
      return @resource_type if defined?(@resource_type)

      @resource_type = define_resource_type
    end

    private

    def define_resource_class
      return controller_path.dup.classify.constantize if resource_type.blank?

      return metastream_resource_class.constantize if resource_for_metastream?

      sti_resource_class.constantize
    rescue StandardError => e
      Rails.logger.error "===========#{e.inspect}================"
      raise Curator::Exceptions::UnknownResourceType, "Unknown Resource Type #{controller_path.dup.classify}"
    end

    def define_serializer_class
      return "#{resource_class.name}Serializer".constantize if !resource_for_metastream?

      "#{controller_path.dup.classify}Serializer".constantize
    rescue StandardError => e
      Rails.logger.error "===========#{e.inspect}================"
      raise Curator::Exceptions::UnknownSerializer, "Unknown serializer for #{controller_path.dup.classify}"
    end

    def sti_resource_class
      return if !resource_for_sti?

      sti_parent_class = controller_path.dup.split('/').last
      sti_class_path = controller_path.dup.gsub(sti_parent_class, resource_type)
      sti_class_path.classify
    end

    def metastream_resource_class
      "Curator::#{resource_type.classify}"
    end

    def resource_for_metastream?
      params.key?(:metastreamable_type)
    end

    def resource_for_sti?
      params.key?(:type)
    end

    def define_resource_type
      return if !resource_for_metastream? && !resource_for_sti?

      return params.fetch(:metastreamable_type) if resource_for_metastream?

      return params.fetch(:type) if resource_for_sti?

      nil
    end
  end
end
