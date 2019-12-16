# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_image, class: 'Curator::Filestreams::Image' do
    association :file_set_of, factory: :curator_digital_object
    sequence(:ark_id) { |n| "commonwealth:#{SecureRandom.hex(n)}" }
    file_set_type { 'Curator::Filestreams::Image' }
    file_name_base { Faker::Artist.name }
    position { 1 }
    pagination { { 'hand_side' => 'left', 'page_type' => 'TOC', 'page_label' => '3' } }
    archived_at { nil }
  end
end
