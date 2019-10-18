FactoryBot.define do
  factory :curator_filestreams_text, class: 'Curator::Filestreams::Text' do
    ark_id { "MyString" }
    file_set_type { 'Curator::Filestreams::Text' }
    file_name_base { "MyString" }
    position { 1 }
    pagination { "" }
    archived_at { nil }
    file_set_of_id { 1 }
  end
end
