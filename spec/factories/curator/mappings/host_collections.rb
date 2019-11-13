# frozen_string_literal: true

FactoryBot.define do
  factory :curator_mappings_host_collection, class: 'Curator::Mappings::HostCollection' do
    association :institution, factory: :curator_institution
    name { Faker::Hipster.sentence }
  end
end
