# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::AdministrativeIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::AdministrativeIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:administratable_object) do
      admin_obj = create(:curator_institution)
      admin_obj.administrative = create(:curator_metastreams_administrative)
      admin_obj.administrative.flagged = true # so we can test indexing
      admin_obj.administrative.oai_header_id = "test:1a234b5"
      admin_obj
    end
    let(:indexed) { indexer.map_record(administratable_object) }
    let(:administrative) { administratable_object.administrative }

    it 'sets the destination_site field' do
      expect(indexed['destination_site_ssim']).to eq administrative.destination_site
    end

    it 'sets the oai_header_id field' do
      expect(indexed['oai_header_id_ss']).to eq [administrative.oai_header_id]
    end

    it 'sets the hosting_status field' do
      expect(indexed['hosting_status_ssi']).to eq [administrative.hosting_status]
    end

    it 'sets the harvesting_status field' do
      expect(indexed['harvesting_status_bsi']).to eq [administrative.harvestable]
    end

    it 'sets the flagged field' do
      expect(indexed['flagged_content_ssi']).to eq [administrative.flagged]
    end
  end
end
