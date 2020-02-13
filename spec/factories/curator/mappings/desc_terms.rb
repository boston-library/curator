# frozen_string_literal: true

FactoryBot.define do
  factory :curator_mappings_desc_term, class: 'Curator::Mappings::DescTerm' do
    association :descriptive, factory: :curator_metastreams_descriptive
    association :mapped_term, factory: :curator_controlled_terms_genre

    trait :specific_genre do
      mapped_term { create(:curator_controlled_terms_genre, basic: false) }
    end

    trait :basic_genre do
      mapped_term { create(:curator_controlled_terms_genre, basic: true) }
    end

    trait :resource_type do
      mapped_term { create(:curator_controlled_terms_resource_type) }
    end

    trait :language do
      mapped_term { create(:curator_controlled_terms_language) }
    end

    trait :subject_topic do
      mapped_term { create(:curator_controlled_terms_subject) }
    end

    trait :subject_name do
      mapped_term { create(:curator_controlled_terms_name) }
    end

    trait :subject_geo do
      mapped_term { create(:curator_controlled_terms_geographic) }
    end
  end
end
