FactoryBot.define do
  factory :curator_collection, class: 'Curator::Collection' do
    ark_id { "MyString" }
    institution_id { 1 }
    name { "MyString" }
    abstract { "MyText" }
    archived_at { nil }
  end
end
