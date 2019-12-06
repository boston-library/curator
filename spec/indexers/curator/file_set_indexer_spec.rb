# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::FileSetIndexer do
  describe 'indexing' do
    # use FileSet from :curator_mappings_exemplary_image factory
    # otherwise exemplary_image indexing doesn't work
    let(:exemplary_image_mapping) { create(:curator_mappings_exemplary_image) }
    let(:file_set) { exemplary_image_mapping.exemplary_file_set }
    let(:indexer) { described_class.new }
    let(:indexed) { indexer.map_record(file_set) }

    it 'sets the file_set_of field' do
      expect(indexed['is_file_set_of_ssim']).to eq [file_set.file_set_of.ark_id]
    end

    it 'sets the file name field' do
      expect(indexed['filename_base_ssi']).to eq [file_set.file_name_base]
    end

    it 'sets the position field' do
      expect(indexed['position_isi']).to eq [file_set.position]
    end

    it 'sets the pagination fields' do
      expect(indexed['page_type_ssi']).to eq [file_set.pagination['page_type']]
      expect(indexed['page_num_label_ssi']).to eq [file_set.pagination['page_label']]
      expect(indexed['page_hand_side_ssi']).to eq [file_set.pagination['hand_side']]
    end

    it 'sets the exemplary image field' do
      expect(indexed['is_exemplary_image_of_ssim']).to eq(
        file_set.exemplary_image_objects.map { |obj| obj.ark_id }
      )
    end
  end
end
