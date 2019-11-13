# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_text, class: 'Curator::Filestreams::Text' do
    association :file_set_of, factory: :curator_digital_object
    ark_id { "commonwealth:#{SecureRandom.hex(5)}" }
    file_set_type { 'Curator::Filestreams::Text' }
    file_name_base { Faker::Books::Lovecraft.tome }
    position { 1 }
    pagination { {} }
    archived_at { nil }
  end
end
