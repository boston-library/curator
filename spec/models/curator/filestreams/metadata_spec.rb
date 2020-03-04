# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'
require_relative '../shared/filestreams/file_attachments'
require_relative '../shared/filestreams/thumbnailable'

RSpec.describe Curator::Filestreams::Metadata, type: :model do
  subject { build(:curator_filestreams_metadata) }

  it_behaves_like 'file_set'

  describe 'Metadata Associations' do
    it { is_expected.to belong_to(:file_set_of).
                        inverse_of(:metadata_file_sets).
                        class_name('Curator::DigitalObject').
                        required }

    it_behaves_like 'thumbnailable'

    it_behaves_like 'has_file_attachments' do
      let(:has_one_file_attachments) { %i(metadata_ia metadata_ia_scan metadata_marc_xml metadata_mods metadata_oai) }
    end
  end
end
