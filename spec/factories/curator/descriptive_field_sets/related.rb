# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_related, class: 'Curator::DescriptiveFieldSets::Related' do
    constituent { Faker::Name.name_with_middle }
    other_format { Array.new(2) { Faker::Lorem.word } }
    referenced_by { create_list(:curator_descriptives_referenced_by, 2) }
    references_url { Array.new(2) { Faker::Internet.url } }
    review_url { Array.new(2) { Faker::Internet.url(host: 'bpl.org') } }
    preceding { create_list(:curator_descriptives_related_title, 2) }
    succeeding { create_list(:curator_descriptives_related_title, 2) }
    skip_create
    initialize_with { new(attributes) }
  end
end
