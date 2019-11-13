# frozen_string_literal: true

FactoryBot.define do
  factory :curator_mappings_issue, class: 'Curator::Mappings::Issue' do
    association :digital_object, factory: :curator_digital_object
    association :issue_of, factory: :curator_digital_object
  end
end
