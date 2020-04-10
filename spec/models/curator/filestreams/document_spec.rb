# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'
require_relative '../shared/filestreams/file_attachments'
require_relative '../shared/filestreams/thumbnailable'

RSpec.describe Curator::Filestreams::Document, type: :model do
  subject { build(:curator_filestreams_document) }

  it_behaves_like 'file_set'

  describe 'Document Associations' do
    it { is_expected.to belong_to(:file_set_of).
                        inverse_of(:document_file_sets).
                        class_name('Curator::DigitalObject').
                        required }

    it_behaves_like 'thumbnailable'
    it_behaves_like 'has_file_attachments' do
      let(:has_one_file_attachments) { %i(document_master document_access image_thumbnail_300) }
    end
  end
end
