# frozen_string_literal: true

module Curator
  module ResourceClass
    extend ActiveSupport::Concern
    def resource_scope
      return resource_class.for_serialization if resource_class && resource_class.respond_to?(:for_serialization)

      resource_class
    end

    def resource_class
      return @resource_class if defined?(@resource_class)

      @resource_class = define_resource_class
    end

    def serializer_class
      return @serializer_class if defined?(@serializer_class)

      @serializer_class = define_serializer_class
    end


    def resource_type
      return @resource_type if defined?(@resource_type)

      @resource_type = define_resource_type
    end

    protected
    def define_resource_class
      return controller_path.dup.classify.safe_constantize if resource_type.blank?

      sti_parent_class = controller_path.dup.split('/').last
      sti_class_path = controller_path.dup.gsub(sti_parent_class, resource_type)
      sti_class_path.classify.safe_constantize
    end

    def define_serializer_class
      return "#{controller_path.dup.classify}Serializer".safe_constantize if resource_class.blank?

      sti_parent_class = controller_path.dup.split('/').last
      sti_class_path = controller_path.dup.gsub(sti_parent_class, resource_type)
      "#{sti_class_path.classify}Serializer".safe_constantize
    end


    def define_resource_type

      return params.to_unsafe_h.fetch(:type) unless params.to_unsafe_h.fetch(:type).blank?

      type = controller_path.dup.classify.demodulize.to_sym
      params.to_unsafe_h.dig(type, :type)
    end
  end
end
