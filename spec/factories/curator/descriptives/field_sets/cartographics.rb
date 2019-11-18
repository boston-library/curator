# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_cartographic, class: 'Curator::Descriptives::Cartographic' do
    scale { ['Scale [ca. 1:18,000]', 'Scale [ca. 1:1,200,000]'] }
    projection { 'azimuthal equal-area proj.' }
    skip_create
    initialize_with { new(attributes) }
  end
end
