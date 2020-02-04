# frozen_string_literal: true

FactoryBot.define do
  factory :curator_metastreams_administrative, class: 'Curator::Metastreams::Administrative' do
    association :administratable, factory: :curator_digital_object
    description_standard { Curator::Metastreams::Administrative.description_standards.keys.sample }
    flagged { [true, false].sample }
    archived_at { nil }
  end
end
