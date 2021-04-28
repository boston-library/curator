# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_geographic, class: 'Curator::ControlledTerms::Geographic' do
    association :authority, factory: :curator_controlled_terms_authority
    label { Faker::Lorem.sentence }
    id_from_auth { Faker::Alphanumeric.alphanumeric(number: 10) }
    coordinates { [Faker::Address.latitude, Faker::Address.longitude].join(',') }
    bounding_box do
      [rand(-150..-120).to_f, rand(-80..-50).to_f, rand(120..150).to_f, rand(50..80).to_f].join(' ')
    end
    area_type { Faker::Address.city_prefix }
    type { 'Curator::ControlledTerms::Geographic' }
  end
end
