# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::AttachmentIndexer, type: :indexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::AttachmentIndexer
      end
    end
    let(:file_set) { create(:curator_filestreams_text) }
    let(:indexer) { indexer_test_class.new }
    let(:indexed) { indexer.map_record(file_set) }
    let(:field_value) { JSON.parse(indexed['attachments_ss']) }

    it 'sets the attachments field' do
      attach_text_file(file_set)
      expect(field_value['text_plain']['byte_size']).to be_an_instance_of(Integer)
      expect(field_value['text_plain']['content_type']).to eq 'text/plain'
      expect(field_value['text_plain']['filename']).to eq 'text_plain.txt'
      expect(field_value['text_plain']['checksum']).to be_an_instance_of(String)
    end
  end
end
