# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_image, class: 'Curator::Filestreams::Image' do
    ark_id
    association :file_set_of, factory: :curator_digital_object
    file_set_type { 'Curator::Filestreams::Image' }
    file_name_base { Faker::Artist.name }
    position { 1 }
    hand_side { 'left' }
    page_type { 'TOC' }
    page_label { '3' }

    after :build do |image_file_set|
      build(:curator_metastreams_administrative, administratable: image_file_set)
      build(:curator_metastreams_workflow, workflowable: image_file_set)
    end
  end
end
