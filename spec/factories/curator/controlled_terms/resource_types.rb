FactoryBot.define do
  factory :curator_controlled_terms_resource_type, class: 'Curator::ControlledTerms::ResourceType' do
    authority_id { 1 }
    term_data { "" }
    type { 'Curator::ControlledTerms::ResourceType'}
    archived_at { "2019-10-18 14:57:26" }
  end
end
