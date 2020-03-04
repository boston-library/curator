# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_metadata, class: 'Curator::Filestreams::Metadata', parent: :curator_filestreams_file_set do
    file_set_type { 'Curator::Filestreams::Metadata' }
    file_name_base { Faker::Internet.uuid }
  end
end
