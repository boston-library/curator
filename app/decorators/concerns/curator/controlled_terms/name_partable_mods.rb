# frozen_string_literal: true

module Curator
  module ControlledTerms::NamePartableMods
    extend ActiveSupport::Concern

    included do
      include InstanceMethods
    end

    module InstanceMethods
      def name
        return super if defined?(super)

        raise Curator::Exceptions::CuratorError, "name is not defined in #{self.class.name}"
      end

      def name_type
        return super if defined?(super)

        raise Curator::Exceptions::CuratorError, "name_type is not defined in #{self.class.name}"
      end

      def name_parts
        return [] if name.blank?

        case name_type
        when 'corporate'
          Curator::Parsers::InputParser.corp_name_part_splitter(name.label).map { |np| Curator::Mappings::NamePartModsPresenter.new(np) }
        when 'personal'
          names_hash = Curator::Parsers::InputParser.pers_name_part_splitter(name.label)
          names_hash.reduce([]) do |ret, (key, val)|
            next ret if val.blank?

            is_date = key == :date_part
            ret << Curator::Mappings::NamePartModsPresenter.new(val, is_date)
            ret
          end
        else
          [Curator::Mappings::NamePartModsPresenter.new(name.label)]
        end
      end
    end
  end
end
