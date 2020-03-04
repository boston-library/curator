# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_audio, class: 'Curator::Filestreams::Audio', parent: :curator_filestreams_file_set do
    file_set_type { 'Curator::Filestreams::Audio' }
  end
end
