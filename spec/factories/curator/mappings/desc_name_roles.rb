# frozen_string_literal: true

FactoryBot.define do
  factory :curator_mappings_desc_name_role, class: 'Curator::Mappings::DescNameRole' do
    association :descriptive, factory: :curator_metastreams_descriptive
    association :name, factory: :curator_controlled_terms_name
    association :role, factory: :curator_controlled_terms_role
  end
end
