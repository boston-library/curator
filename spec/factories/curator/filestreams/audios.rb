FactoryBot.define do
  factory :curator_filestreams_audio, class: 'Curator::Filestreams::Audio' do
    association :file_set_of, factory: :curator_digital_object
    ark_id { "commonwealth:#{SecureRandom.hex(5)}" }
    file_set_type { 'Curator::Filestreams::Audio' }
    file_name_base { Faker::File.file_name(dir: 'foo') }
    position { 1 }
    pagination { {} }
    archived_at { nil }
  end
end
