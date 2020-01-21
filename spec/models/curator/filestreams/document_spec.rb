# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'

RSpec.describe Curator::Filestreams::Document, type: :model do
  subject { create(:curator_filestreams_document) }

  it_behaves_like 'file_set'

  describe 'Document Associations' do
    it { is_expected.to belong_to(:file_set_of).
                        inverse_of(:document_file_sets).
                        class_name('Curator::DigitalObject').
                        required }

    describe 'File Attachments' do
      let!(:document_attachments) { %i(document_master document_access image_thumbnail_300) }

      it { is_expected.to respond_to(*document_attachments) }

      it 'expects each of the attachment types to be a kind of ActiveStorage::Attachment' do
        document_attachments.each do |attachment|
          expect(subject.send(attachment)).to be_an_instance_of(ActiveStorage::Attached::One)
        end
      end
    end
  end
end
