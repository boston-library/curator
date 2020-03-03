# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_video, class: 'Curator::Filestreams::Video' do
    ark_id
    association :file_set_of, factory: :curator_digital_object
    file_set_type { 'Curator::Filestreams::Video' }
    file_name_base { Faker::TvShows::Simpsons.character }
    position { 1 }

    after :build do |video_file_set|
      build(:curator_metastreams_administrative, administratable: video_file_set)
      build(:curator_metastreams_workflow, workflowable: video_file_set)
    end
  end
end
