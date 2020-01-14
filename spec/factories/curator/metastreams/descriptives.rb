# frozen_string_literal: true

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
    place_of_publication { Faker::Lorem.sentence }
    publisher { Faker::Lorem.sentence }
    issuance { Faker::Lorem.sentence }
    frequency { Faker::Lorem.sentence }
    extent { Faker::Lorem.sentence }
    physical_location_department { Faker::Lorem.sentence }
    physical_location_shelf_locator { Faker::Lorem.sentence }
    series { Faker::Lorem.sentence }
    subseries { Faker::Lorem.sentence }
    subsubseries { Faker::Lorem.sentence }
    rights { Faker::Lorem.sentence }
    access_restrictions { Faker::Lorem.sentence }
    toc_url { Faker::Internet.url }
    toc { Faker::Lorem.paragraph }
    abstract { Faker::Lorem.paragraph }
    archived_at { nil }

    transient do
      genre_count { nil }
    end

    after :create do |descriptive, options|
      descriptive.identifier = create_list(:curator_descriptives_identifier, 3)
      descriptive.date = create(:curator_descriptives_date)
      descriptive.note = create_list(:curator_descriptives_note, 3)
      descriptive.cartographic = create(:curator_descriptives_cartographic)
      descriptive.publication = create(:curator_descriptives_publication)
      descriptive.related = create(:curator_descriptives_related)
      descriptive.title = create(:curator_descriptives_title_set)
      descriptive.subject_other = create(:curator_descriptives_subject)
      create_list(:curator_mappings_desc_term, options.genre_count, descriptive: descriptive) if options.genre_count
    end
  end
end
