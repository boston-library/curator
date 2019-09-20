# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::Authority < ApplicationRecord


    validates :name, presence: true
    validates :code, uniqueness: { allow_nil: true }
    validates :base_url, uniqueness: {scope: [:code],  allow_nil: true }, format: { with: URI::regexp(%w(http https)), allow_nil: true }

    has_many :genres, inverse_of: :authority, class_name: 'ControlledTerms::Genre', foreign_key: :authority_id
    has_many :geographics, inverse_of: :authority, class_name: 'ControlledTerms::Geographic', foreign_key: :authority_id
    has_many :languages, inverse_of: :authority, class_name: 'ControlledTerms::Language', foreign_key: :authority_id
    has_many :licenses, inverse_of: :authority, class_name: 'ControlledTerms::License', foreign_key: :authority_id
    has_many :names, inverse_of: :authority, class_name: 'ControlledTerms""Name', foreign_key: :authority_id
    has_many :resource_types, inverse_of: :authority, class_name: 'ControlledTerms::ResourceType', foreign_key: :authority_id
    has_many :roles, inverse_of: :authority, class_name: 'ControlledTerms::Role', foreign_key: :authority_id
    has_many :subjects, inverse_of: :authority, class_name: 'ControlledTerms::Subject', foreign_key: :authority_id

    protected
    def should_get_cannonical?
      self.name.blank? && self.base_url.present?
    end
  end
end
