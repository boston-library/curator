# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_metadata, class: 'Curator::Filestreams::Metadata' do
    association :file_set_of, factory: :curator_digital_object
    sequence(:ark_id) { |n| "commonwealth:#{SecureRandom.hex(n)}" }
    file_set_type { 'Curator::Filestreams::Metadata' }
    file_name_base { Faker::Internet.uuid }
    position { 1 }
    pagination { {} }
    archived_at { nil }
  end
end
