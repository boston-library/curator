# frozen_string_literal: true

module Curator
  class ControlledTerms::Authority < ApplicationRecord
    AUTH_NAME_KEY='http://www.w3.org/2000/01/rdf-schema#label'.freeze
    private_constant :AUTH_NAME_KEY

    before_validation :get_canonical_name, if: :should_get_cannonical_name?

    validates :name, presence: true
    validates :code, uniqueness: { allow_nil: true }
    validates :base_url, uniqueness: {scope: [:code],  allow_nil: true }, format: { with: URI::regexp(%w(http https)), allow_nil: true }

    with_options inverse_of: :authority, dependent: :destroy, foreign_key: :authority_id do
      has_many :genres, class_name: ControlledTerms.genre_class_name
      has_many :geographics, class_name: ControlledTerms.geographic_class_name
      has_many :languages, class_name: ControlledTerms.language_class_name
      has_many :licenses, class_name: ControlledTerms.license_class_name
      has_many :names, class_name: ControlledTerms.name_class_name
      has_many :resource_types, class_name: ControlledTerms.resource_type_class_name
      has_many :roles, class_name: ControlledTerms.role_class_name
      has_many :subjects, class_name: ControlledTerms.subject_class_name
    end

    def cannonical_json_format
      case self.code
      when 'gmgpc', 'lctgm', 'naf', 'lcsh', 'lcgft', 'iso639-2', 'marcrelator', 'resourceTypes'
        '.skos.json'
      when 'aat', 'tgn', 'ulan'
        '.jsonld'
      else
        nil
      end
    end

    protected

    def should_get_cannonical_name?
      self.name.blank? && self.base_url.present?
    end

    private

    def get_canonical_name
      name_json_block = case self.cannonical_json_format
                        when '.jsonld'
                          ->(json_body){ json_body[AUTH_NAME_KEY] if json_body[AUTH_NAME_KEY].present? }
                        when '.skos.json'
                          ->(json_body){
                            label_el = json_body.collect{|aj| aj[AUTH_NAME_KEY] if aj.key?(AUTH_NAME_KEY)}.compact.flatten.shift
                            label_el['@value'] if label_el.present?
                          }
                        else
                          nil
      end

      unless name_json_block.blank?
        self.name = ControlledTerms::CannonicalLabelService.call(url: base_url, json_path: self.cannonical_json_format, &name_json_block)
      end
    end
  end
end
