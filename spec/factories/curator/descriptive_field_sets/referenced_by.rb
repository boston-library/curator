# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_referenced_by, class: 'Curator::DescriptiveFieldSets::ReferencedBy' do
    label { Faker::Lorem.sentence(word_count: 3) }
    url { Faker::Internet.url(host: 'nrs.harvard.edu') }
    skip_create
    initialize_with { new(attributes) }
  end
end
