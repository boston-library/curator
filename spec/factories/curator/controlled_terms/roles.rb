# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_role, class: 'Curator::ControlledTerms::Role' do
    association :authority, factory: :curator_controlled_terms_authority
    label { Faker::Lorem.sentence }
    id_from_auth { Faker::Alphanumeric.alphanumeric(number: 10) }
    type { 'Curator::ControlledTerms::Role' }
  end
end
