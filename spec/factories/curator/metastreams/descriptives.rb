# frozen_string_literal: true

FactoryBot.define do
  factory :curator_metastreams_descriptive, class: 'Curator::Metastreams::Descriptive' do
    descriptable { nil }
    for_digital_object
    association :physical_location, factory: :curator_controlled_terms_name
    association :license, factory: :curator_controlled_terms_license
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

    trait :manuscript? do
      resource_type_manuscript { true }
    end

    trait :for_digital_object do
      after :build do |descriptive|
        descriptive.descriptable = build(:curator_digital_object, descriptive: descriptive) if descriptive.descriptable.blank?
      end
    end

    trait :with_all_desc_terms do
      transient do
        desc_term_count { nil }
      end

      after :build do |descriptive, options|
        %i(specific_genre language resource_type subject_topic subject_name subject_geo).each do |desc_term_type|
          descriptive.desc_terms << build_list(:curator_mappings_desc_term, options.desc_term_count, desc_term_type) if options.desc_term_count
        end
        descriptive.name_roles = build_list(:curator_mappings_desc_name_role, options.desc_term_count) if options.desc_term_count
      end
    end

    transient do
      genre_count { nil }
      name_role_count { nil }
      language_count { nil }
      resource_type_count { nil }
      subject_count { nil }
      host_collection_count { 1 }
    end

    after :create do |descriptive, options|
      create_list(:curator_mappings_desc_term, options.genre_count, :specific_genre, descriptive: descriptive) if options.genre_count
      %i(subject_topic subject_name subject_other).each do |subject_type|
        create_list(:curator_mappings_desc_term, options.subject_count, subject_type, descriptive: descriptive) if options.subject_count
      end
      %i(language resource_type).each do |desc_term_type|
        create_list(:curator_mappings_desc_term, options.send("#{desc_term_type}_count"), :language, descriptive: descriptive) if options.send("#{desc_term_type}_count")
      end
      create_list(:curator_mappings_desc_name_role, options.name_role_count, descriptive: descriptive) if options.name_role_count
      create_list(:curator_mappings_desc_host_collection, options.host_collection_count, descriptive: descriptive) if options.host_collection_count
    end
  end
end
