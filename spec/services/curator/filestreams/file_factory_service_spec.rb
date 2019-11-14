# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Filestreams::FileFactoryService, type: :service do
  before(:all) do
    # create parent FileSet
    @object_json = load_json_fixture('file')
    @file_set = create(:curator_filestreams_image)
    @object_json['filestream_of']['ark_id'] = @file_set.ark_id
    @object_json['metadata']['ingest_filepath'] = file_fixture('sample-thumbnail.jpg').to_s
    expect do
      @file = described_class.call(json_data: @object_json)
    end.to change { ActiveStorage::Blob.count }.by(1)
  end

  describe '#call' do
    subject { @file }

    it 'sets the file info correctly' do
      expect(subject.filename.to_s).to eq @object_json['file_name']
      expect(subject.created_at).to eq Time.zone.parse(@object_json['created_at'])
      expect(subject.metadata['ingest_filepath']).to eq @object_json['metadata']['ingest_filepath']
    end

    describe 'object relationships' do
      subject { @file.attachments.first }

      it 'sets the attachment' do
        expect(subject).to be_an_instance_of(ActiveStorage::Attachment)
        expect(subject.name).to eq @object_json['file_type'].underscore.insert(-4, '_')
        expect(subject.record_type).to eq @file_set.class.superclass.name
      end
    end
  end
end
