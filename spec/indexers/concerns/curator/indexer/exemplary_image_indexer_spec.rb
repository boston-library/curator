# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::ExemplaryImageIndexer, type: :indexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::ExemplaryImageIndexer
      end
    end
    let(:file_set) do
      fs = create(:curator_filestreams_image)
      attach_thumbnail_file(fs)
      fs
    end
    let!(:digital_object) do
      digital_obj = create(:curator_digital_object)
      create(:curator_mappings_exemplary_image, exemplary_object: digital_obj, exemplary_file_set: file_set)
      digital_obj
    end
    let(:indexer) { indexer_test_class.new }
    let(:indexed) { indexer.map_record(digital_object) }

    it 'sets the exemplary_image field' do
      expect(indexed['exemplary_image_ssi']).to include(file_set.ark_id)
    end

    it 'sets the exemplary_image_key_base field' do
      expect(indexed['exemplary_image_key_base_ss']).to be_an_instance_of(String)
    end
  end
end
