# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'

RSpec.describe Curator::Filestreams::Text, type: :model do
  subject { create(:curator_filestreams_text) }

  it_behaves_like 'file_set'

  describe 'Text Associations' do
    it { is_expected.to belong_to(:file_set_of).
                        inverse_of(:text_file_sets).
                        class_name('Curator::DigitalObject').
                        required }

    describe 'File Attachments' do
      let!(:text_attachments) { %i(text_plain text_coordinates_master) }

      it { is_expected.to respond_to(*text_attachments) }

      it 'expects each of the attachment types to be a kind of ActiveStorage::Attachment' do
        text_attachments.each do |attachment|
          expect(subject.send(attachment)).to be_an_instance_of(ActiveStorage::Attached::One)
        end
      end
    end
  end
end
