# frozen_string_literal: true

module Curator
  class Mappings::GroupedNameRoleModsPresenter
    # DESCRIPTION This presenter  class aides in grouping roles by a name for a desriptives's name_roles relation. It is also ...
    ## ... a required param for the Curator::Mappings::NameRoleModsDecorator

    # @param Hash[Curator::ControlledTerms::Name => Array[Curator::Mappings::DescNameRole]]
    # @return Array[Curator::Mappings::GroupedNameRoleModsPresenter]
    # USAGE:
    ## obj = Curator.digital_object_class.for_serialization.find_by(...)
    ## name_roles_group = obj.descriptive.name_roles.group_by(&:name)
    ## grouped_name_roles = Curator::Mappings::GroupedNameRoleModsPresenter.wrap_multiple(name_roles_group)
    ## decorated_mods_name_roles = Curator::Mappings::NameRoleModsDecorator.wrap_multiple(grouped_name_roles)
    def self.wrap_multiple(grouped_name_roles = {})
      return [] if grouped_name_roles.blank?

      grouped_name_roles.inject([]) do |ret, (name, name_roles)|
        ret << new(name, name_roles)
      end
    end

    attr_reader :name, :roles

    # @param name [Curator::ControlledTerms::Name]
    # @param name_roles [Array[Curator::Mappings::DescNameRole]]
    # @return [Curator::Mappings::GroupedNameRoleModsPresenter]
    def initialize(name, name_roles = [])
      @name = name
      @roles = name_roles.map(&:role)
    end
  end
end
