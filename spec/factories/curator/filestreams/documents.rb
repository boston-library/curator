# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_document, class: 'Curator::Filestreams::Document' do
    ark_id
    association :file_set_of, factory: :curator_digital_object
    file_set_type { 'Curator::Filestreams::Document' }
    file_name_base { Faker::Books::Lovecraft.tome }
    position { 1 }
    pagination { {} }
    archived_at { nil }
  end
end
