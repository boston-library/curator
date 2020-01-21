# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'

RSpec.describe Curator::Filestreams::Video, type: :model do
  subject { create(:curator_filestreams_video) }

  it_behaves_like 'file_set'

  describe 'Video Associations' do
    it { is_expected.to belong_to(:file_set_of).
                        inverse_of(:video_file_sets).
                        class_name('Curator::DigitalObject').
                        required }

    describe 'File Attachments' do
      let!(:video_attachments) { %i(document_master document_access image_thumbnail_300 text_plain video_master video_access) }

      it { is_expected.to respond_to(*video_attachments) }

      it 'expects each of the attachment types to be a kind of ActiveStorage::Attachment' do
        video_attachments.each do |attachment|
          expect(subject.send(attachment)).to be_an_instance_of(ActiveStorage::Attached::One)
        end
      end
    end
  end
end
