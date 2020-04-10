# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_ereader, class: 'Curator::Filestreams::Ereader', parent: :curator_filestreams_file_set do
    file_set_type { 'Curator::Filestreams::Ereader' }
    file_name_base { Faker::Book.publisher }
  end
end
