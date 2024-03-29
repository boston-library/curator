# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_resource_type, class: 'Curator::ControlledTerms::ResourceType' do
    association :authority, factory: :curator_controlled_terms_authority
    label { Faker::Lorem.sentence }
    id_from_auth { Faker::Alphanumeric.alphanumeric(number: 10) }
    type { 'Curator::ControlledTerms::ResourceType' }
  end
end
