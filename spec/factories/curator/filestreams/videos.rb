# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_video, class: 'Curator::Filestreams::Video', parent: :curator_filestreams_file_set do
    file_set_type { 'Curator::Filestreams::Video' }
    file_name_base { Faker::TvShows::Simpsons.character }
  end
end
