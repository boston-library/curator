# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_file_set, class: 'Curator::Filestreams::FileSet' do
    ark_id
    with_metastreams
    association :file_set_of, factory: :curator_digital_object
    file_name_base { Faker::Music.album }
    file_set_type { Curator::Filestreams.file_set_types.map { |type| "Curator::Filestreams::#{type}" }.sample }
    position { 1 }

    trait :with_metastreams do
      administrative { nil }
      workflow { nil }

      after :build do |file_set|
        file_set.administrative = build(:curator_metastreams_administrative,
                                        :for_file_set,
                                        administratable: file_set) if file_set.administrative.blank?

        file_set.workflow = build(:curator_metastreams_workflow,
                                  :for_file_set,
                                  workflowable: file_set) if file_set.workflow.blank?
      end
    end
  end
end
