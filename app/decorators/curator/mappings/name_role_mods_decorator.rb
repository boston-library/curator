# frozen_string_literal: true

module Curator
  class Mappings::NameRoleModsDecorator < Decorators::BaseDecorator
    class RoleTerm

    end

    def name
      super if __getobj__.respond_to?(:name)
    end

    def role
      super if __getobj__.respond_to?(:role)
    end

    def name_parts
      return [] if name.blank?

      case name_type
      when 'corporate'
        Curator::Parsers::InputParser.corp_name_part_splitter(name.label).map { |np| NamePart.new(np) }
      when 'personal'
        names_hash = Curator::Parsers::InputParser.pers_name_part_splitter(name.label)
        names_hash.reduce([]) do |ret, (key, val)|
          next ret if val.blank?

          is_date = key == :date_part
          ret << Mappings::NamePartModsPresenter.new(val, is_date)
          ret
        end
      else
        [Mappings::NamePartModsPresenter.new(name.label)]
      end
    end

    def name_type
      name&.name_type
    end

    def name_authority
      name&.authority_code
    end

    def name_authority_uri
      name&.authority_base_url
    end

    def name_value_uri
      name&.value_uri
    end

    def role_term
      Mappings::RoleTermModsPresenter.new(role) if role.present?
    end

    def blank?
      return true if __getobj__.blank?

      name.blank? && role.blank?
    end
  end
end
