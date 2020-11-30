# frozen_string_literal: true

RSpec.shared_examples 'thumbnailable', type: :model do
  describe 'has_one_attached #image_thumbnail_300' do
    it { is_expected.to have_one_attached(:image_thumbnail_300) }

    it 'expects each of the attachment types to be a kind of ActiveStorage::Attachment' do
      expect(subject.image_thumbnail_300).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end
end
