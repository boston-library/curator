FactoryBot.define do
  factory :curator_controlled_terms_authority, class: 'Curator::ControlledTerms::Authority' do
    name { "MyString" }
    code { "MyString" }
    base_url { "MyString" }
    archived_at { nil }
  end
end
