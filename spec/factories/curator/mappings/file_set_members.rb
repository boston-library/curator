FactoryBot.define do
  factory :curator_mappings_file_set_member, class: 'Curator::Mappings::FileSetMember' do
    association :digital_object, factory: :curator_digital_object
    association :file_set, factory: :curator_filestreams_image

    trait :document_member do
      file_set { create(:curator_filestreams_document) }
    end

    trait :audio_member do
      file_set { create(:curator_filestreams_audio) }
    end

    trait :video_member do
      file_set { create(:curator_filestreams_video) }
    end
  end
end
