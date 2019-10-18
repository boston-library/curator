FactoryBot.define do
  factory :curator_controlled_terms_name, class: 'Curator::ControlledTerms::Name' do
    authority_id { 1 }
    term_data { "" }
    type { 'Curator::ControlledTerms::Name' }
    archived_at { "2019-10-18 14:57:00" }
  end
end
