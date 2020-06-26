# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_title, class: 'Curator::DescriptiveFieldSets::Title' do
    label { "The #{Faker::Lorem.word}" }
    subtitle { Faker::Lorem.sentence }
    display { 'Below Map' }
    display_label { Faker::Lorem.sentence }
    usage { nil }
    type { %w(uniform alternative).sample }
    supplied { [true, false].sample }
    language { ['eng', 'fr'].sample }
    authority_code { 'naf' }
    id_from_auth { 'n00020514' }
    sequence(:part_number) { |n| "Vol. #{n}" }
    part_name { Faker::Lorem.sentence }

    trait :primary do
      display { 'primary' }
      usage { 'primary' }
      type { 'primary' }
    end

    skip_create
    initialize_with { new(attributes) }
  end
end
