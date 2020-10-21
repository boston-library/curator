# frozen_string_literal: true

RSpec.shared_examples 'attachable', type: :service do
  specify { expect(@file_set).to be_an_instance_of(Curator::Filestreams::FileSet)  }
  specify { expect(@file_set.image_thumbnail_300).to be_attached }

  describe 'attached file' do
    subject { @file_set.image_thumbnail_300 }

    let(:file_json) { @files_json.first }

    it 'sets the file info correctly' do
      expect(subject.filename.to_s).to eq file_json['file_name']
      # expect(subject.created_at).to eq Time.zone.parse(file_json['created_at'])
      expect(subject.metadata['ingest_filepath']).to eq file_json['metadata']['ingest_filepath']
    end
  end
end
