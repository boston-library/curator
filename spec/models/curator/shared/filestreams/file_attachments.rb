# frozen_string_literal: true

RSpec.shared_examples 'has_one_attached', type: :model do
  describe '#has_one_attached' do
    it { is_expected.to respond_to(*has_one_file_attachments) }

    it 'expects each of the attachment types to be a kind of ActiveStorage::Attachment' do
      has_one_file_attachments.each do |attachment|
        expect(subject.send(attachment)).to be_an_instance_of(ActiveStorage::Attached::One)
      end
    end
  end
end

RSpec.shared_examples 'has_many_attached', type: :model do
  describe '#has_many_attached' do
    it { is_expected.to respond_to(*has_many_file_attachments) }

    it 'expects each of the attachment types to be a kind of ActiveStorage::Attachment' do
      has_many_file_attachments.each do |attachment|
        expect(subject.send(attachment)).to be_an_instance_of(ActiveStorage::Attached::Many)
      end
    end
  end
end

RSpec.shared_examples 'has_file_attachments', type: :model do
  describe 'File Attachments' do
    it_behaves_like 'has_one_attached'
  end
end
