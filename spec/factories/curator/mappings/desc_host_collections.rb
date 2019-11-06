# frozen_string_literal: true

FactoryBot.define do
  factory :curator_mappings_desc_host_collection, class: 'Curator::Mappings::DescHostCollection' do
    association :host_collection, factory: :curator_mappings_host_collection
    association :descriptive, factory: :curator_metastreams_descriptive
  end
end
