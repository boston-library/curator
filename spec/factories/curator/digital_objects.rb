FactoryBot.define do
  factory :curator_digital_object, class: 'Curator::DigitalObject' do
    ark_id { "MyString" }
    admin_set_id { 1 }
    archived_at { nil }
  end
end
