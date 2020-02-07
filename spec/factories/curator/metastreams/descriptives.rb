# frozen_string_literal: true

FactoryBot.define do
  factory :curator_metastreams_descriptive, class: 'Curator::Metastreams::Descriptive' do
    association :descriptable, factory: :curator_digital_object
    association :physical_location, factory: :curator_controlled_terms_name
    identifier { create_list(:curator_descriptives_identifier, 3) }
    date { create(:curator_descriptives_date) }
    note { create_list(:curator_descriptives_note, 3) }
    cartographic { create(:curator_descriptives_cartographic) }
    publication { create(:curator_descriptives_publication) }
    related { create(:curator_descriptives_related) }
    title { create(:curator_descriptives_title_set) }
    subject_other { create(:curator_descriptives_subject) }
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

    trait :manuscript? do
      resource_type_manuscript { true }
    end

    trait :with_all_desc_terms do
      transient do
        desc_term_count { nil }
      end

      after :create do |descriptive, options|
        create_list(:curator_mappings_desc_term, options.desc_term_count, :specific_genre, descriptive: descriptive) if options.desc_term_count
        create_list(:curator_mappings_desc_term, options.desc_term_count, :language, descriptive: descriptive) if options.desc_term_count
        create_list(:curator_mappings_desc_term, options.desc_term_count, :resource_type, descriptive: descriptive) if options.desc_term_count
        create_list(:curator_mappings_desc_term, options.desc_term_count, :license, descriptive: descriptive) if options.desc_term_count
        create_list(:curator_mappings_desc_term, options.desc_term_count, :subject_topic, descriptive: descriptive) if options.desc_term_count
        create_list(:curator_mappings_desc_term, options.desc_term_count, :subject_name, descriptive: descriptive) if options.desc_term_count
        create_list(:curator_mappings_desc_term, options.desc_term_count, :subject_geo, descriptive: descriptive) if options.desc_term_count
        create_list(:curator_mappings_desc_name_role, options.desc_term_count, descriptive: descriptive) if options.desc_term_count
      end
    end


    transient do
      genre_count { nil }
      name_role_count { nil }
      language_count { nil }
      resource_type_count { nil }
      license_count { nil }
      subject_count { nil }
      host_collection_count { 1 }
    end

    after :create do |descriptive, options|
      create_list(:curator_mappings_desc_term, options.genre_count, :specific_genre, descriptive: descriptive) if options.genre_count
      create_list(:curator_mappings_desc_term, options.language_count, :language, descriptive: descriptive) if options.language_count
      create_list(:curator_mappings_desc_term, options.resource_type_count, :resource_type, descriptive: descriptive) if options.resource_type_count
      create_list(:curator_mappings_desc_term, options.license_count, :license, descriptive: descriptive) if options.license_count
      create_list(:curator_mappings_desc_term, options.subject_count, :subject_topic, descriptive: descriptive) if options.subject_count
      create_list(:curator_mappings_desc_term, options.subject_count, :subject_name, descriptive: descriptive) if options.subject_count
      create_list(:curator_mappings_desc_term, options.subject_count, :subject_geo, descriptive: descriptive) if options.subject_count
      create_list(:curator_mappings_desc_name_role, options.name_role_count, descriptive: descriptive) if options.name_role_count
      create_list(:curator_mappings_desc_host_collection, options.host_collection_count, descriptive: descriptive) if options.host_collection_count
    end
  end
end
