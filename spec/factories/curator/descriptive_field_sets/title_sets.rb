# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_title_set, class: 'Curator::DescriptiveFieldSets::TitleSet' do
    primary { create(:curator_descriptives_title, :primary) }
    other { create_list(:curator_descriptives_title, 5) }
    skip_create
    initialize_with { new(attributes) }
  end
end
