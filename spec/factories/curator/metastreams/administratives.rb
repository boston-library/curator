FactoryBot.define do
  factory :curator_metastreams_administrative, class: 'Curator::Metastreams::Administrative' do
    administratable_type { "MyString" }
    administratable_id { 1 }
    description_standard { 1 }
    harvestable { false }
    flagged { false }
    destination_site { "MyString" }
    archived_at { nil }
  end
end
