# frozen_string_literal: true

FactoryBot.define do
  factory :curator_metastreams_administrative, class: 'Curator::Metastreams::Administrative' do
    association :administratable, factory: :curator_digital_object
    description_standard { Curator::Metastreams::Administrative.description_standards.keys.sample }

    trait :is_flagged do
      flagged { true }
    end

    trait :non_havestable do
      harvestable { false }
    end
  end
end
