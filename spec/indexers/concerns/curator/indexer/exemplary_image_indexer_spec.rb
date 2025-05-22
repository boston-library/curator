# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::ExemplaryImageIndexer, type: :indexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::ExemplaryImageIndexer
      end
    end

    let!(:file_set) do
      fs = create(:curator_filestreams_image, file_set_of: digital_object)
      attach_thumbnail_file(fs)
      fs
    end

    let!(:institution) { create(:curator_institution) }
    let!(:admin_set) { create(:curator_collection, institution: institution) }
    let!(:digital_object) { create(:curator_digital_object, admin_set: admin_set) }
    let!(:indexer) { indexer_test_class.new }

    let!(:obj_indexed) do
      create(:curator_mappings_exemplary_image, exemplary_object: digital_object, exemplary_file_set: file_set)
      indexer.map_record(digital_object)
    end

    let(:inst_indexed) do
      create(:curator_mappings_exemplary_image, exemplary_object: institution, exemplary_file_set: file_set)
      indexer.map_record(institution)
    end

    let(:col_indexed) do
      create(:curator_mappings_exemplary_image, exemplary_object: admin_set, exemplary_file_set: file_set)
      indexer.map_record(admin_set)
    end

    it 'sets the exemplary_image field' do
      expect(obj_indexed['exemplary_image_ssi']).to include(file_set.ark_id)
      expect(col_indexed['exemplary_image_ssi']).to include(file_set.ark_id)
      expect(inst_indexed['exemplary_image_ssi']).to include(file_set.ark_id)
    end

    it 'sets the exemplary_image_key_base field' do
      expect(obj_indexed['exemplary_image_key_base_ss']).to be_an_instance_of(String)
      expect(col_indexed['exemplary_image_key_base_ss']).to be_an_instance_of(String)
      expect(inst_indexed['exemplary_image_key_base_ss']).to be_an_instance_of(String)
    end

    it 'does not set the exemplary_image_digobj_ss for digital objects' do
      expect(obj_indexed).not_to have_key('exemplary_image_digobj_ss')
      expect(obj_indexed['exemplary_image_digobj_ss']).to be_nil
    end

    it 'sets the exemplary_image_digobj_ss field for collectiosn and institutions' do
      expect(col_indexed['exemplary_image_digobj_ss']).to be_an_instance_of(String).and eql(digital_object.ark_id)
      expect(inst_indexed['exemplary_image_digobj_ss']).to be_an_instance_of(String).and eql(digital_object.ark_id)
    end
  end
end
