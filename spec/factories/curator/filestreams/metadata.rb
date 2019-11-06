# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_metadata, class: 'Curator::Filestreams::Metadata' do
    association :file_set_of, factory: :curator_digital_object
    ark_id { "commonwealth:#{SecureRandom.hex(5)}" }
    file_set_type { 'Curator::Filestreams::Metadata' }
    file_name_base { Faker::File.file_name(ext: 'xml') }
    position { 1 }
    pagination { {} }
    archived_at { nil }
  end
end
