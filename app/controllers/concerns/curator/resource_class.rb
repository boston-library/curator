# frozen_string_literal: true

module Curator
  module ResourceClass
    extend ActiveSupport::Concern
    def resource_scope
      return resource_class.for_serialization if resource_class && resource_class.respond_to?(:for_serialization)

      resource_class
    end

    def serialized_resource(resource)
      serializer_class.new(resource, @adapter_key).render
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

    # NOTE: in certain cases were going to need to get the parent class
    def define_resource_class
      return controller_path.dup.classify.constantize if resource_type.blank?

      sti_parent_class = controller_path.dup.split('/').last
      sti_class_path = controller_path.dup.gsub(sti_parent_class, resource_type)
      sti_class_path.classify.constantize
    rescue StandardError
      raise Curator::Exceptions::UnknownResourceType, "Unknown Resource Type #{controller_path.dup.classify}"
    end

    def define_serializer_class
      return "#{controller_path.dup.classify}Serializer".constantize if resource_class.blank?

      sti_parent_class = controller_path.dup.split('/').last
      sti_class_path = controller_path.dup.gsub(sti_parent_class, resource_type)
      "#{sti_class_path.classify}Serializer".constantize
    rescue StandardError
      raise Curator::Exceptions::UnknownSerializer, "Unknown serializer for #{controller_path.dup.classify}"
    end

    def define_resource_type
      return params.fetch(:type) if params.fetch(:type, nil).present?

      nil
    end
  end
end
