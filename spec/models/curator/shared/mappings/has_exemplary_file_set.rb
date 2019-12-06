# frozen_string_literal: true

RSpec.shared_examples 'has_exemplary_file_set', type: :model do
  describe '#exemplary_file_set' do
    it 'returns the exemplary FileSet' do
      exemplary_file_set = create(:curator_filestreams_image)
      exemplary_mapping = Curator::Mappings::ExemplaryImage.new(exemplary_object: subject,
                                                                exemplary_file_set: exemplary_file_set)
      exemplary_mapping.save!
      expect(subject.exemplary_file_set.ark_id).to eq exemplary_file_set.ark_id
    end
  end
end
