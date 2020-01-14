# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_ereader, class: 'Curator::Filestreams::Ereader' do
    association :file_set_of, factory: :curator_digital_object
    sequence(:ark_id) { |n| "commonwealth:#{SecureRandom.hex(rand([n, 8].max..[n, 32].max))}" }
    file_set_type { 'Curator::Filestreams::Ereader' }
    file_name_base { Faker::Book.publisher }
    position { 1 }
    pagination { {} }
    archived_at { nil }
  end
end
