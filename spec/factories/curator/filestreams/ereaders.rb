# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_ereader, class: 'Curator::Filestreams::Ereader' do
    association :file_set_of, factory: :curator_digital_object
    ark_id { "commonwealth:#{SecureRandom.hex(5)}" }
    file_set_type { 'Curator::Filestreams::Ereader' }
    file_name_base { Faker::File.file_name(ext: 'tif') }
    position { 1 }
    pagination { {} }
    archived_at { nil }
  end
end
