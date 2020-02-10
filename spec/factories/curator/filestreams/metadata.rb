# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_metadata, class: 'Curator::Filestreams::Metadata' do
    ark_id
    association :file_set_of, factory: :curator_digital_object
    file_set_type { 'Curator::Filestreams::Metadata' }
    file_name_base { Faker::Internet.uuid }
    position { 1 }
    archived_at { nil }
  end
end
