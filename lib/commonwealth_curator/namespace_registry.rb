module CommonwealthCurator
  module NamespaceRegistry
    def self.included(base)
      base.extend(ClassMethods)
    end
    # thread_mattr_accessor :dependencies_to_load
    module ClassMethods
      def namespace_accessor(name)
        namespace_const = const_get(name)
        module_eval <<-RUBY, __FILE__, __LINE__
          def self.#{name.to_s.underscore}
            #{namespace_const}
          end
        RUBY
      end
    end
  end
end
