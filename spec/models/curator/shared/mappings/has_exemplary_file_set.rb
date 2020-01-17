# frozen_string_literal: true

RSpec.shared_examples 'has_exemplary_file_set', type: :model do
  describe '#exemplary_file_set' do
    let!(:exemplary_file_set) { create(:curator_filestreams_image) }

    before(:each) do
      subject.exemplary_image_mapping = build(:curator_mappings_exemplary_image, exemplary_file_set: exemplary_file_set)
      subject.save!
    end

    it 'returns the exemplary FileSet' do
      expect(subject.exemplary_image_mapping).to be_truthy
      expect(subject.exemplary_file_set.ark_id).to eq(exemplary_file_set.ark_id)
    end
  end
end
