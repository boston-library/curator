# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_image, class: 'Curator::Filestreams::Image', parent: :curator_filestreams_file_set do
    file_set_type { 'Curator::Filestreams::Image' }
    file_name_base { Faker::Artist.name }
    hand_side { 'left' }
    page_type { 'TOC' }
    page_label { '3' }

    trait :with_primary_image do
      after :create do |image|
        file_name = 'image_primary.tiff'
        image.image_primary.attach(io: File.open(Curator::Engine.root.join('spec', 'fixtures', 'files', file_name).to_s), filename: file_name, content_type: 'image/tiff')
      end
    end
  end
end
