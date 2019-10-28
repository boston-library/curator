FactoryBot.define do
  factory :curator_filestreams_document, class: 'Curator::Filestreams::Document' do
    association :file_set_of, factory: :curator_digital_object
    ark_id { "commonwealth:#{SecureRandom.hex(5)}" }
    file_set_type { 'Curator::Filestreams::Document' }
    file_name_base { "MyString" }
    position { 1 }
    pagination { {} }
    archived_at { nil }
  end
end
