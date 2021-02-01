# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'
require_relative '../shared/filestreams/file_attachments'
require_relative '../shared/filestreams/derivative_methods'
require_relative '../shared/versionable'

RSpec.describe Curator::Filestreams::Text, type: :model do
  subject { build(:curator_filestreams_text) }

  it_behaves_like 'file_set'
  include_examples 'derivative_methods'
  it_behaves_like 'versionable'

  describe 'Text Associations' do
    it { is_expected.to belong_to(:file_set_of).
                        inverse_of(:text_file_sets).
                        class_name('Curator::DigitalObject').
                        required }

    it_behaves_like 'has_file_attachments' do
      let(:has_one_file_attachments) { %i(text_plain text_coordinates_master) }
    end
  end
end
