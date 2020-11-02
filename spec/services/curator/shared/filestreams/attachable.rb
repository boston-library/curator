# frozen_string_literal: true

RSpec.shared_examples 'attachable', type: :service do
  specify { expect(@file_set).to be_a_kind_of(Curator::Filestreams::FileSet) }
  specify { expect(@file_set.image_thumbnail_300).to be_attached }

  describe 'attached file' do
    subject { @file_set.image_thumbnail_300_blob }

    let(:file_json) { @files_json.first }

    it 'sets the file info correctly' do
      expect(subject.filename.to_s).to eq(file_json['file_name'])
      expect(subject.metadata['ingest_filepath']).to eq(file_json['metadata']['ingest_filepath'])
      expect(subject.byte_size).to eq(file_json['byte_size'])
      expect(subject.checksum).to eq(Base64.strict_encode64([file_json['checksum']].pack('H*')))
    end
  end
end
