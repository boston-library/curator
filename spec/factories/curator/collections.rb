# frozen_string_literal: true

FactoryBot.define do
  factory :curator_collection, class: 'Curator::Collection' do
    association :institution, factory: :curator_institution
    sequence(:ark_id) { |n| "commonwealth:#{SecureRandom.hex(n)}" }
    name { "#{Faker::FunnyName.four_word_name} Collection" }
    abstract { Faker::Lorem.paragraph }
    archived_at { nil }
  end
end
