# frozen_string_literal: true

FactoryBot.define do
  factory :curator_collection, class: 'Curator::Collection' do
    association :institution, factory: :curator_institution
    ark_id { "commonwealth:#{SecureRandom.hex(5)}" }
    name { "#{Faker::FunnyName.four_word_name} Collection" }
    abstract { Faker::Lorem.paragraph }
    archived_at { nil }
  end
end
