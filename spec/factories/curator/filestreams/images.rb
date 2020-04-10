# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_image, class: 'Curator::Filestreams::Image', parent: :curator_filestreams_file_set do
    file_set_type { 'Curator::Filestreams::Image' }
    file_name_base { Faker::Artist.name }
    hand_side { 'left' }
    page_type { 'TOC' }
    page_label { '3' }
  end
end
