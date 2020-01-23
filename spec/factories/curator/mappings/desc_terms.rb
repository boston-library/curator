# frozen_string_literal: true

FactoryBot.define do
  factory :curator_mappings_desc_term, class: 'Curator::Mappings::DescTerm' do
    association :descriptive, factory: :curator_metastreams_descriptive
    association :mapped_term, factory: :curator_controlled_terms_genre
  end
end
