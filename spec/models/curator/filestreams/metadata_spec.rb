# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'
require_relative '../shared/filestreams/file_attachments'
require_relative '../shared/filestreams/thumbnailable'
require_relative '../shared/versionable'

RSpec.describe Curator::Filestreams::Metadata, type: :model do
  subject { build(:curator_filestreams_metadata) }

  it_behaves_like 'file_set'
  it_behaves_like 'versionable'

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

  describe '#required_derivatives_complete?' do
    it 'expects :DEFAULT_REQUIRED_DERIVATIVES to be a defined constant' do
      expect(described_class).to be_const_defined(:DEFAULT_REQUIRED_DERIVATIVES)
    end

    it 'is expected to respond_to #required_derivatives_complete?' do
      expect(subject).to respond_to(:required_derivatives_complete?).with(1).argument
      expect(subject).to_not be_required_derivatives_complete
    end
  end

  describe 'Callbacks' do
    describe '.after_update_commit' do
      subject { create(:curator_filestreams_metadata) }

      it 'runs #set_as_exemplary callback on :update' do
        expect(subject).to receive(:set_as_exemplary).at_least(:once)
        subject.touch
      end
    end
  end
end
