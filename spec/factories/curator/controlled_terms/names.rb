# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_name, class: 'Curator::ControlledTerms::Name' do
    association :authority, factory: :curator_controlled_terms_authority
    label { Faker::Lorem.sentence }
    id_from_auth { Faker::Alphanumeric.alphanumeric(number: 10) }
    affiliation { Faker::University.name }
    name_type { Curator::ControlledTerms::Name::VALID_NAME_TYPES.sample }
    type { 'Curator::ControlledTerms::Name' }
  end
end
