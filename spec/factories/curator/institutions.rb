# frozen_string_literal: true

FactoryBot.define do
  factory :curator_institution, class: 'Curator::Institution' do
    sequence(:ark_id) { |_n| "commonwealth:#{SecureRandom.hex(5)}" }
    name { Faker::University.name }
    abstract { Faker::Lorem.paragraph }
    url { Faker::Internet.unique.url(host: 'example.org') }
    archived_at { nil }
  end
end
