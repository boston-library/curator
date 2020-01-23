# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'
require_relative '../shared/filestreams/file_attachments'

RSpec.describe Curator::Filestreams::Video, type: :model do
  subject { create(:curator_filestreams_video) }

  it_behaves_like 'file_set'

  describe 'Video Associations' do
    it { is_expected.to belong_to(:file_set_of).
                        inverse_of(:video_file_sets).
                        class_name('Curator::DigitalObject').
                        required }

    it_behaves_like 'has_file_attachments' do
      let(:has_one_file_attachments) { %i(document_master document_access image_thumbnail_300 text_plain video_master video_access) }
    end
  end
end
