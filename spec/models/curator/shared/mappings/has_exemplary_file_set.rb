# frozen_string_literal: true

RSpec.shared_examples 'has_exemplary_file_set', type: :model do
  describe '#exemplary_file_set' do
    let(:exemplary_file_set) { create(:curator_filestreams_image) }

    before(:each) do
      create(:curator_mappings_exemplary_image, exemplary_file_set: exemplary_file_set, exemplary_object: subject)
    end

    it 'returns the exemplary FileSet' do
      expect(subject.reload.exemplary_image_mapping).to be_truthy
      expect(subject.reload.exemplary_file_set.ark_id).to eq(exemplary_file_set.ark_id)
    end
  end
end
