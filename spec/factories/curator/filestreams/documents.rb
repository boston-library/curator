# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_document, class: 'Curator::Filestreams::Document', parent: :curator_filestreams_file_set do
    file_set_type { 'Curator::Filestreams::Document' }
    file_name_base { Faker::Books::Lovecraft.tome }
  end
end
