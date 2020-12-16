# frozen_string_literal: true

RSpec.shared_examples 'has_one_attached', type: :model do
  describe '#has_one_attached' do
    it 'is expected to have_one_attached for all :has_one_file_attachments' do
      has_one_file_attachments.each do |attachment|
        expect(subject).to have_one_attached(attachment)
      end
    end

    it 'expects each of the attachment types to be a kind of ActiveStorage::Attachment' do
      has_one_file_attachments.each do |attachment|
        expect(subject.send(attachment)).to be_an_instance_of(ActiveStorage::Attached::One)
      end
    end
  end
end

RSpec.shared_examples 'has_file_attachments', type: :model do
  describe 'File Attachments' do
    it_behaves_like 'has_one_attached'
  end
end

# has_many_attached not currently used, keep in case needed later (remove skip: true)
RSpec.shared_examples 'has_many_attached', type: :model do
  describe '#has_many_attached', skip: true do
    it 'is expected to have_many_attached for all :has_many_file_attachments' do
      has_many_file_attachments.each do |attachment|
        expect(subject).to have_many_attached(attachment)
      end
    end

    it 'expects each of the attachment types to be a kind of ActiveStorage::Attachment' do
      has_many_file_attachments.each do |attachment|
        expect(subject.send(attachment)).to be_an_instance_of(ActiveStorage::Attached::Many)
      end
    end
  end
end