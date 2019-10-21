FactoryBot.define do
  factory :curator_digital_object, class: 'Curator::DigitalObject' do
    ark_id { "commonwealth:#{SecureRandom.hex(5)}" }
    association :admin_set, factory: :curator_collection
    archived_at { nil }
  end
end
