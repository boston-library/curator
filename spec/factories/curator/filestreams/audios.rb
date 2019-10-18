FactoryBot.define do
  factory :curator_filestreams_audio, class: 'Curator::Filestreams::Audio' do
    ark_id { "MyString" }
    file_set_type { 'Curator::Filestreams::Audio' }
    file_name_base { "MyString" }
    position { 1 }
    pagination { "" }
    archived_at { nil }
    file_set_of_id { 1 }
  end
end
