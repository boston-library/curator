# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'

RSpec.describe Curator::Filestreams::Ereader, type: :model do
  subject { create(:curator_filestreams_ereader) }

  it_behaves_like 'file_set'

  describe 'Ereader Associations' do
    it { is_expected.to belong_to(:file_set_of).
                        inverse_of(:ereader_file_sets).
                        class_name('Curator::DigitalObject').
                        required }

    describe 'File Attachments' do
      it { is_expected.to respond_to(:ebook_access, :image_thumbnail_300) }

      it 'expects each of the attachment types to be a kind of ActiveStorage::Attachment' do
        expect(subject.ebook_access).to be_an_instance_of(ActiveStorage::Attached::Many)
        expect(subject.image_thumbnail_300).to be_an_instance_of(ActiveStorage::Attached::One)
      end
    end
  end
end
