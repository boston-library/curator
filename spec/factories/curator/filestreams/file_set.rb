# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_file_set, class: 'Curator::Filestreams::FileSet' do
    association :file_set_of, factory: :curator_digital_object
    sequence(:ark_id) { |n| "commonwealth:#{SecureRandom.hex(n)}" }
    file_set_type { 'Curator::Filestreams::Audio' }
    file_name_base { Faker::Music.album }
    position { 1 }
    pagination { {} }
    archived_at { nil }
  end
end