# frozen_string_literal: true
module Curator
  module NamespaceAccessor
    def self.included(base)
      base.extend(ClassMethods)
      #NOTE THE ORDER HERE MATTERS!
      base.module_eval do
        def self.init_namespace_accessors
          namespace_accessor :controlled_terms
          namespace_accessor :metastreams
          namespace_accessor :filestreams
          namespace_accessor :mappings

          namespace_klass_accessor :digital_object
          namespace_klass_accessor :institution
          namespace_klass_accessor :collection
        end
      end
    end

    def self.extended(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      VALID_NAMESPACES = %i(ControlledTerms Filestreams Mappings Metastreams).freeze

      VALID_NAMESPACE_CLASSES=%i(Institution
        Collection
        DigitalObject
        Authority
        Genre
        Geographic
        Language
        License
        Name
        ResourceType
        Role
        Subject
        Audio
        Document
        Ereader
        Image
        Metadata
        Text
        Video
        CollectionMember
        DescHostCollection
        DescNameRole
        DescTerm
        ExemplaryImage
        HostCollection
        Administrative
        Descriptive
        Workflow
        ).freeze

      private_constant :VALID_NAMESPACES
      private_constant :VALID_NAMESPACE_CLASSES

      def namespace_accessor(name, &block)
        name = name.to_s.camelize  if name.to_s != name.to_s.camelize
        raise Curator::CuratorError, "Invaild namespace #{name.to_s}" unless VALID_NAMESPACES.include?(name.to_sym)
        module_eval <<-RUBY, __FILE__, __LINE__
          def self.#{name.to_s.underscore}
            #{name.to_s}
          end
        RUBY
      end

      def namespace_klass_accessor(klass_name)
        klass_name = klass_name.to_s.camelize  if klass_name.to_s != klass_name.to_s.camelize
        raise Curator::CuratorError, "Invaild namespace class #{klass_name.to_s}" unless VALID_NAMESPACE_CLASSES.include?(klass_name.to_sym)
        module_eval <<-RUBY, __FILE__, __LINE__
          def self.#{klass_name.to_s.underscore}_class
            #{klass_name.to_s}
          end
        RUBY
      end
    end
  end
end
