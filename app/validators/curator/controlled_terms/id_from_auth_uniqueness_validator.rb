# frozen_string_literal: true

module Curator
  class ControlledTerms::IdFromAuthUniquenessValidator < ActiveModel::Validator
    # @param[required] record [Curator::ControlledTerms::Nomenclature]
    def validate(record)
      return if record.id_from_auth.blank? || record.authority.blank?

      record.errors.add(:id_from_auth, "#{record.id_from_auth} has already been taken for #{record.class}!") if id_from_auth_exists?(record)
    end

    private

    # @param[required] record [Curator::ControlledTerms::Nomenclature]
    def id_from_auth_exists?(record)
      record.class.where(authority: record.authority).where("controlled_terms_nomenclatures.term_data->>'id_from_auth' = ?", record.id_from_auth).exists?
    end
  end
end
