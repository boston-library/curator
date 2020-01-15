FactoryBot.define do
  factory :curator_mappings_file_set_member, class: 'Curator::Mappings::FileSetMember' do
    association :digital_object, factory: :curator_digital_object
    association :file_set, factory: :curator_filestreams_image
  end
end
