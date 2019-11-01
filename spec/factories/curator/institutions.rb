# frozen_string_literal: true

FactoryBot.define do
  factory :curator_institution, class: 'Curator::Institution' do
    ark_id { "commonwealth:#{SecureRandom.hex(5)}" }
    name { Faker::University.name }
    abstract { Faker::Lorem.paragraph }
    archived_at { nil }
  end
end
