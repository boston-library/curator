# frozen_string_literal: true

module Curator
  module NamespaceAccessor
    def self.included(base)
      base.extend(ClassMethods)
      #NOTE THE ORDER HERE MATTERS
      base.module_eval do
        def self.init_namespace_accessors
          puts "Initializing namespace accessors"
          namespace_accessors :controlled_terms, :filestreams, :mappings, :metastreams
          namespace_klass_accessors :institution, :collection, :digital_object
        end
      end
    end

    def self.extended(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      VALID_NAMESPACES = %w(ControlledTerms Filestreams Mappings Metastreams).freeze

      VALID_NAMESPACE_CLASSES=%w(Institution
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
                                 Issue
        ).freeze

      private_constant :VALID_NAMESPACES
      private_constant :VALID_NAMESPACE_CLASSES

      def namespace_accessors(*namespaces)
        namespaces.each do |namespace|
          const_name = namespace.to_s.camelize
          raise Curator::CuratorError, "Invaild namespace #{const_name.to_s}" unless VALID_NAMESPACES.include?(const_name)

          module_eval <<-RUBY, __FILE__, __LINE__
            def self.#{namespace}
              const_get('#{const_name}')
            end
          RUBY
        end
      end

      def namespace_klass_accessors(*klass_names)
        klass_names.each do |klass_name|
          klass_const_name = klass_name.to_s.camelize
          raise Curator::CuratorError, "Invaild namespace class #{klass_const_name}" unless VALID_NAMESPACE_CLASSES.include?(klass_const_name)

          module_eval <<-RUBY, __FILE__, __LINE__
            def self.#{klass_name}_class_name
              to_s + '::' + '#{klass_const_name}'
            end

            def self.#{klass_name}_class
              const_get(#{klass_name}_class_name)
            end
          RUBY
        end
      end
    end
  end
end
