# frozen_string_literal: true

FactoryBot.define do
  factory :curator_mappings_exemplary_image, class: 'Curator::Mappings::ExemplaryImage' do
    association :exemplary_object, factory: :curator_digital_object
    association :exemplary_file_set, factory: :curator_filestreams_image
  end
end
