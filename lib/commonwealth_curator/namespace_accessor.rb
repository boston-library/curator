# frozen_string_literal: true
module CommonwealthCurator
  module NamespaceAccessor
    def self.included(base)
      base.extend(ClassMethods)
      base.module_eval do
        def self.init_namespace_accessors
          namespace_klass_accessor :digital_object
          namespace_klass_accessor :institution
          namespace_klass_accessor :collection

          namespace_accessor :controlled_terms do
            extend NamespaceAccessor
            namespace_klass_accessor :authority
            namespace_klass_accessor :genre
            namespace_klass_accessor :geographic
            namespace_klass_accessor :language
            namespace_klass_accessor :license
            namespace_klass_accessor :name
            namespace_klass_accessor :resource_type
            namespace_klass_accessor :role
            namespace_klass_accessor :subject
          end
          namespace_accessor :metastreams do
            extend NamespaceAccessor
            namespace_klass_accessor :administrative
            namespace_klass_accessor :descriptive
            namespace_klass_accessor :workflow
          end
          namespace_accessor :filestreams do
            extend NamespaceAccessor
            namespace_klass_accessor :file_set
          end
          namespace_accessor :mappings do
            extend NamespaceAccessor
            namespace_klass_accessor :collection_member
            namespace_klass_accessor :desc_host_collection
            namespace_klass_accessor :desc_name_role_mapping
            namespace_klass_accessor :desc_term_mapping
            namespace_klass_accessor :exemplary_image
            namespace_klass_accessor :host_collection
          end
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
        FileSet
        CollectionMember
        DescHostCollection
        DescNameRoleMapping
        DescTermMapping
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
        raise CommonwealthCurator::CuratorError, "Invaild namespace #{name.to_s}" unless VALID_NAMESPACES.include?(name.to_sym)
        module_eval <<-RUBY, __FILE__, __LINE__
          def self.#{name.to_s.underscore}
            #{name.to_s}
          end
        RUBY
        if block_given?
          const_name = const_get(name.to_sym)
          const_name.module_eval &block if block_given?
        end
      end

      def namespace_klass_accessor(klass_name)
        klass_name = klass_name.to_s.camelize  if klass_name.to_s != klass_name.to_s.camelize
        raise CommonwealthCurator::CuratorError, "Invaild namespace class #{klass_name.to_s}" unless VALID_NAMESPACE_CLASSES.include?(klass_name.to_sym)
        module_eval <<-RUBY, __FILE__, __LINE__
          def self.#{klass_name.to_s.underscore}_class
            #{klass_name.to_s}
          end
        RUBY
      end
    end
  end
end
