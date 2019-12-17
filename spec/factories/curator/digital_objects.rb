# frozen_string_literal: true

FactoryBot.define do
  factory :curator_digital_object, class: 'Curator::DigitalObject' do
    sequence(:ark_id) { |n| "commonwealth:#{SecureRandom.hex(n)}" }
    association :admin_set, factory: :curator_collection
    archived_at { nil }
  end
end
