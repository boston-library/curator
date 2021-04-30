# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_genre, class: 'Curator::ControlledTerms::Genre' do
    association :authority, factory: :curator_controlled_terms_authority
    label { Faker::Lorem.sentence }
    id_from_auth { Faker::Alphanumeric.alphanumeric(number: 10) }
    basic { [true, false].sample }
    type { 'Curator::ControlledTerms::Genre' }
  end
end
