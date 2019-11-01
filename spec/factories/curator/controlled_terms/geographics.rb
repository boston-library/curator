# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_geographic, class: 'Curator::ControlledTerms::Geographic' do
    association :authority, factory: :curator_controlled_terms_authority
    term_data { {} }
    type { "Curator::ControlledTerms::Geographic" }
    archived_at { nil }
  end
end
