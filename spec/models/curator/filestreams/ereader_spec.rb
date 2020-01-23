# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'
require_relative '../shared/filestreams/file_attachments'
RSpec.describe Curator::Filestreams::Ereader, type: :model do
  subject { create(:curator_filestreams_ereader) }

  it_behaves_like 'file_set'

  describe 'Ereader Associations' do
    it { is_expected.to belong_to(:file_set_of).
                        inverse_of(:ereader_file_sets).
                        class_name('Curator::DigitalObject').
                        required }

    it_behaves_like 'has_file_attachments' do
      let(:has_one_file_attachments) { %i(image_thumbnail_300) }
      let(:has_many_file_attachments) { %i(ebook_access) }
      it_behaves_like 'has_many_attached'
    end
  end
end
