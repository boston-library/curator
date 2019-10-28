FactoryBot.define do
  factory :curator_metastreams_descriptive, class: 'Curator::Metastreams::Descriptive' do
    association :descriptable, factory: :curator_digital_object
    association :physical_location, factory: :curator_controlled_terms_name
    identifier_json { {} }
    title_json { {} }
    date_json { {} }
    note_json { {} }
    subject_json { {} }
    related_json { {} }
    cartographics_json { {} }
    publication_json { {} }
    digital_origin { 1 }
    origin_event { 1 }
    text_direction { 1 }
    resource_type_manuscript { false }
    place_of_publication { "MyString" }
    publisher { "MyString" }
    issuance { "MyString" }
    frequency { "MyString" }
    extent { "MyString" }
    physical_location_department { "MyString" }
    physical_location_shelf_locator { "MyString" }
    series { "MyString" }
    subseries { "MyString" }
    rights { "MyString" }
    access_restrictions { "MyString" }
    toc_url { "MyString" }
    toc { "MyText" }
    abstract { Faker::Lorem.paragraph }
    archived_at { nil }
  end
end
