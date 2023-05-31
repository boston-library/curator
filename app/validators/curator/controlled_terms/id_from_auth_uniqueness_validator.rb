# frozen_string_literal: true

module Curator
  class ControlledTerms::IdFromAuthUniquenessValidator < ActiveModel::Validator
    def validate(record)
      return if record.id_from_auth.blank? || record.authority.blank?

      record.errors.add(:id_from_auth, "id_from_auth #{record.id_from_auth} has alredy been taken!") if id_from_auth_exists?(record)
    end

    private

    def id_from_auth_exists?(record)
      record.class.where(authority: record.authority).where("controlled_terms_nomenclatures.term_data->>'id_from_auth' = ?", record.id_from_auth).count > 1
    end
  end
end
