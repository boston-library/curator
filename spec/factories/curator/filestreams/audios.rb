# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_audio, class: 'Curator::Filestreams::Audio' do
    ark_id
    association :file_set_of, factory: :curator_digital_object
    file_set_type { 'Curator::Filestreams::Audio' }
    file_name_base { Faker::Music.album }
    position { 1 }

    after :build do |audio_file_set|
      build(:curator_metastreams_administrative, administratable: audio_file_set)
      build(:curator_metastreams_workflow, workflowable: audio_file_set)
    end
  end
end
