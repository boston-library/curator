FactoryBot.define do
  factory :curator_institution, class: 'Curator::Institution' do
    ark_id { "MyString" }
    name { "MyString" }
    abstract { "MyText" }
    archived_at { nil }
  end
end
