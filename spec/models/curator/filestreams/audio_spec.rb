# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'

RSpec.describe Curator::Filestreams::Audio, type: :model do
  subject { create(:curator_filestreams_audio) }

  it_behaves_like 'file_set'

  describe 'Audio Associations' do
    it { is_expected.to belong_to(:file_set_of).
                        inverse_of(:audio_file_sets).
                        class_name('Curator::DigitalObject').
                        required }

    describe 'File Attachments' do
      let!(:audio_attachments) { %i(audio_access audio_master document_access document_master text_plain) }

      it { is_expected.to respond_to(*audio_attachments) }

      it 'expects each of the attachment types to be a kind of ActiveStorage::Attachment' do
        audio_attachments.each do |attachment|
          expect(subject.send(attachment)).to be_an_instance_of(ActiveStorage::Attached::One)
        end
      end
    end
  end
end
