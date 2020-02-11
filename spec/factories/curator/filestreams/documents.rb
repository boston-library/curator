# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_document, class: 'Curator::Filestreams::Document' do
    ark_id
    association :file_set_of, factory: :curator_digital_object
    file_set_type { 'Curator::Filestreams::Document' }
    file_name_base { Faker::Books::Lovecraft.tome }
    position { 1 }
    archived_at { nil }

    trait :with_metastreams do
      after :create do |document_file_set|
        create(:curator_metastreams_administrative, administratable: document_file_set)
        create(:curator_metastreams_workflow, workflowable: document_file_set)
      end
    end
  end
end
