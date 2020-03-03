# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_file_set, class: 'Curator::Filestreams::FileSet' do
    ark_id
    association :file_set_of, factory: :curator_digital_object
    file_set_type { Curator::Filestreams.file_set_types.map { |type| "Curator::Filestreams::#{type}" }.sample }
    file_name_base { Faker::Music.album }
    position { 1 }

    after :build do |random_file_set|
      build(:curator_metastreams_administrative, administratable: random_file_set)
      build(:curator_metastreams_workflow, workflowable: random_file_set)
    end
  end
end
