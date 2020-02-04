# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_name, class: 'Curator::ControlledTerms::Name' do
    association :authority, factory: :curator_controlled_terms_authority
    label { Faker::Lorem.sentence }
    id_from_auth { Faker::Alphanumeric.alphanumeric(number: 10) }
    affiliation { Faker::University.name }
    name_type { Faker::Company.buzzword } # NOTE: Should we validate name_types by list? 
    type { 'Curator::ControlledTerms::Name' }
    archived_at { nil }
  end
end
