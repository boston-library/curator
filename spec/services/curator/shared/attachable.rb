# frozen_string_literal: true

RSpec.shared_examples 'attachable', type: :service do
  specify { expect(record.image_thumbnail_300).to be_attached }

  describe 'attached file' do
    subject { record.image_thumbnail_300_blob }

    it 'sets the file info correctly' do
      expect(subject.key).to eq("#{record.class.name.demodulize.downcase.pluralize}/#{record.ark_id}/image_thumbnail_300.jpg")
      expect(subject.filename.to_s).to eq(file_json['file_name'])
      expect(subject.metadata['ingest_filepath']).to eq(file_json['metadata']['ingest_filepath'])
      expect(subject.service_name).to eq('derivatives')
      expect(subject.byte_size).to eq(file_json['byte_size'])
      expect(subject.checksum).to eq(Base64.strict_encode64([file_json['checksum_md5']].pack('H*')))
    end
  end
end
