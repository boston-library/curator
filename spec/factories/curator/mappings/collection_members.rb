# frozen_string_literal: true

FactoryBot.define do
  factory :curator_mappings_collection_member, class: 'Curator::Mappings::CollectionMember' do
    association :collection, factory: :curator_collection
    association :digital_object, factory: :curator_digital_object
  end
end
