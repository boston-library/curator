# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'
require_relative '../shared/filestreams/file_attachments'
require_relative '../shared/filestreams/derivative_methods'
require_relative '../shared/filestreams/thumbnailable'
require_relative '../shared/versionable'

RSpec.describe Curator::Filestreams::Image, type: :model do
  subject { build(:curator_filestreams_image) }

  it_behaves_like 'file_set'
  include_examples 'derivative_methods'
  it_behaves_like 'versionable'

  describe 'Image Associations' do
    it { is_expected.to belong_to(:file_set_of).
                        inverse_of(:image_file_sets).
                        class_name('Curator::DigitalObject').
                        required }

    it_behaves_like 'thumbnailable'

    it_behaves_like 'has_file_attachments' do
      let(:has_one_file_attachments) { %i(document_access image_master image_negative_master image_georectified_master image_access_800 image_service text_coordinates_master text_coordinates_access text_plain) }
    end
  end
end
