# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_license, class: 'Curator::ControlledTerms::License' do
    label { ['public domain', 'creative commons', 'contact host'].sample }
    uri { Faker::Internet.url }
    type { 'Curator::ControlledTerms::License' }
  end
end
