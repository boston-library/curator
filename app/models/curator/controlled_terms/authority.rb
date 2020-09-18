# frozen_string_literal: true

module Curator
  class ControlledTerms::Authority < ApplicationRecord
    validates :name, presence: true
    validates :code, uniqueness: { allow_nil: true }
    validates :base_url, uniqueness: { scope: :code, allow_nil: true }, format: { with: URI.regexp(%w(http https)), allow_nil: true }, if: -> { code.present? }

    with_options inverse_of: :authority, dependent: :destroy, foreign_key: :authority_id do
      has_many :genres, class_name: 'Curator::ControlledTerms::Genre'
      has_many :geographics, class_name: 'Curator::ControlledTerms::Geographic'
      has_many :languages, class_name: 'Curator::ControlledTerms::Language'
      has_many :licenses, class_name: 'Curator::ControlledTerms::License'
      has_many :names, class_name: 'Curator::ControlledTerms::Name'
      has_many :resource_types, class_name: 'Curator::ControlledTerms::ResourceType'
      has_many :roles, class_name: 'Curator::ControlledTerms::Role'
      has_many :subjects, class_name: 'Curator::ControlledTerms::Subject'
    end

    # code below for fetching canonical name is deprecated
    # authorities are pre-loaded using db/seeds.rb with data from BPLDC Authority API
    # keeping this code here in case we update/revert our approach

    # AUTH_NAME_KEY = 'http://www.w3.org/2000/01/rdf-schema#label'
    # private_constant :AUTH_NAME_KEY

    # before_validation :fetch_canonical_name, if: :should_fetch_canonical_name?

    # protected

    # def should_fetch_canonical_name?
    #   name.blank? && base_url.present?
    # end

    # private

    # def fetch_canonical_name
    #   name_json_block = case canonical_json_format
    #                     when '.jsonld'
    #                       ->(json_body) { json_body[AUTH_NAME_KEY].presence }
    #                     when '.skos.json'
    #                       lambda { |json_body|
    #                         label_el = json_body.collect { |aj| aj[AUTH_NAME_KEY].presence }.compact.flatten.shift
    #                         label_el['@value'] if label_el.present?
    #                       }
    #                     end

    #   self.name = ControlledTerms::AuthorityService.call(url: base_url,
    #                                                      json_path: canonical_json_format,
    #                                                      &name_json_block) if name_json_block.present?
    # end
  end
end
