# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'

RSpec.describe Curator::Filestreams::Metadata, type: :model do
  subject { create(:curator_filestreams_metadata) }

  it_behaves_like 'file_set'

  describe 'Metadata Associations' do
    it { is_expected.to belong_to(:file_set_of).
                        inverse_of(:metadata_file_sets).
                        class_name('Curator::DigitalObject').
                        required }

    describe 'File Attachments' do
      let!(:metadata_attachments) { %i(metadata_ia metadata_ia_scan metadata_marc_xml metadata_mods metadata_oai image_thumbnail_300) }

      it { is_expected.to respond_to(*metadata_attachments) }

      it 'expects each of the attachment types to be a kind of ActiveStorage::Attachment' do
        metadata_attachments.each do |attachment|
          expect(subject.send(attachment)).to be_an_instance_of(ActiveStorage::Attached::One)
        end
      end
    end
  end
end
