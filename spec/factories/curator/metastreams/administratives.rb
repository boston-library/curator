# frozen_string_literal: true

FactoryBot.define do
  factory :curator_metastreams_administrative, class: 'Curator::Metastreams::Administrative' do
    description_standard { Curator::Metastreams::Administrative.description_standards.keys.sample }
    administratable { nil }
    for_institution

    trait :is_flagged do
      flagged { Curator::Metastreams::Administrative::VALID_FLAGGED_VALUES.sample }
    end

    trait :non_havestable do
      harvestable { false }
    end

    trait :for_institution do
      after :build do |administrative|
        administrative.administratable = build(:curator_institution, administrative: administrative) if administrative.administratable.blank?
      end
    end

    trait :for_collection do
      after :build do |administrative|
        administrative.administratable = build(:curator_collection, administrative: administrative) if administrative.administratable.blank?
      end
    end

    trait :for_object do
      after :build do |administrative|
        administrative.administratable = build(:curator_digital_object, administrative: administrative) if administrative.administratable.blank?
      end
    end

    trait :for_oai_object do
      oai_header_id { "oai:test:#{SecureRandom.hex}" }
      for_object
    end

    trait :for_file_set do
      transient do
        file_type { Curator.filestreams.file_set_types.map { |type| "curator_filestreams_#{type}".to_sym }.sample }
      end

      after :build do |administrative|
        administrative.administratable = build(file_type, administrative: administrative) if administrative.administratable.blank?
      end
    end
  end
end
