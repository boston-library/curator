# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_rights_statement, class: 'Curator::ControlledTerms::RightsStatement' do
    label { Faker::Lorem.sentence }
    uri { Faker::Internet.url }
    type { 'Curator::ControlledTerms::RightsStatement' }
  end
end
