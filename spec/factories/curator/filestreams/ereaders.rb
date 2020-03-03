# frozen_string_literal: true

FactoryBot.define do
  factory :curator_filestreams_ereader, class: 'Curator::Filestreams::Ereader' do
    ark_id
    association :file_set_of, factory: :curator_digital_object
    file_set_type { 'Curator::Filestreams::Ereader' }
    file_name_base { Faker::Book.publisher }
    position { 1 }

    after :build do |ereader_file_set|
      build(:curator_metastreams_administrative, administratable: ereader_file_set)
      build(:curator_metastreams_workflow, workflowable: ereader_file_set)
    end
  end
end
