FactoryBot.define do
  factory :curator_controlled_terms_role, class: 'Curator::ControlledTerms::Role' do
    authority_id { 1 }
    term_data { "" }
    type {'Curator::ControlledTerms::Role' }
    archived_at { nil }
  end
end
