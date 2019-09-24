# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::Authority < ApplicationRecord
    AUTH_LABEL_KEY='http://www.w3.org/2000/01/rdf-schema#label'.freeze
    private_constant :AUTH_LABEL_KEY

    before_validation :get_canonical_name, if: :should_get_cannonical_name?

    validates :name, presence: true
    validates :code, uniqueness: { allow_nil: true }
    validates :base_url, uniqueness: {scope: [:code],  allow_nil: true }, format: { with: URI::regexp(%w(http https)), allow_nil: true }

    has_many :genres, inverse_of: :authority, class_name: 'CommonwealthCurator::ControlledTerms::Genre', foreign_key: :authority_id, dependent: :destroy
    has_many :geographics, inverse_of: :authority, class_name: 'CommonwealthCurator::ControlledTerms::Geographic', foreign_key: :authority_id, dependent: :destroy
    has_many :languages, inverse_of: :authority, class_name: 'CommonwealthCurator::ControlledTerms::Language', foreign_key: :authority_id, dependent: :destroy
    has_many :licenses, inverse_of: :authority, class_name: 'CommonwealthCurator::ControlledTerms::License', foreign_key: :authority_id, dependent: :destroy
    has_many :names, inverse_of: :authority, class_name: 'CommonwealthCurator::ControlledTerms::Name', foreign_key: :authority_id, dependent: :destroy
    has_many :resource_types, inverse_of: :authority, class_name: 'CommonwealthCurator::ControlledTerms::ResourceType', foreign_key: :authority_id, dependent: :destroy
    has_many :roles, inverse_of: :authority, class_name: 'CommonwealthCurator::ControlledTerms::Role', foreign_key: :authority_id, dependent: :destroy
    has_many :subjects, inverse_of: :authority, class_name: 'CommonwealthCurator::ControlledTerms::Subject', foreign_key: :authority_id, dependent: :destroy

    def cannonical_json_format
      case self.code
      when 'gmgpc', 'lctgm', 'naf', 'lcsh', 'lcgft', 'iso639-2', 'marcrelators', 'resourceTypes'
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
      when 'jsonld'
        ->(json_body){ json_body[AUTH_NAME_KEY] if json_body[AUTH_NAME_KEY].present? }
      when 'skos.json'
        ->(json_body){
          label_el = json_body.collect{|aj| aj[AUTH_NAME_KEY] if aj.key?(AUTH_NAME_KEY)}.compact.flatten.shift
          label_el['@value'] if label_el.present?
        }
      else
        nil
      end
      unless name_json_block.blank?
        self.name = ControlledTerms::CannonicalLabelService.call(url: value_uri, json_path: json_path, &name_json_block)
      end
    end
  end
end
