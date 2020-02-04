# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_geographic, class: 'Curator::ControlledTerms::Geographic' do
    association :authority, factory: :curator_controlled_terms_authority
    label { Faker::Lorem.sentence }
    id_from_auth { Faker::Alphanumeric.alphanumeric(number: 10) }
    coordinates { [Faker::Address.latitude, Faker::Address.longitude].join(',') }
    bounding_box { (0..100).to_a.sample(4).join(' ') }
    area_type { Faker::Address.city_prefix }
    type { 'Curator::ControlledTerms::Geographic' }
    archived_at { nil }
  end
end
