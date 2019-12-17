# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::RightsLicenseIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::RightsLicenseIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:descriptive) do
      descriptive_ms = create(:curator_metastreams_descriptive)
      descriptive_ms.licenses << create(:curator_controlled_terms_license)
      descriptive_ms
    end
    let(:descriptable_object) { descriptive.descriptable }
    let(:indexed) { indexer.map_record(descriptable_object) }

    it 'sets the rights field' do
      expect(indexed['rights_ss']).to eq [descriptive.rights]
    end

    it 'sets the restrictions_on_access field' do
      expect(indexed['restrictions_on_access_ss']).to eq [descriptive.access_restrictions]
    end

    it 'sets the license field' do
      expect(indexed['license_ssm']).to eq descriptive.licenses.map(&:label)
    end

    it 'sets the license_uri field' do
      expect(indexed['license_uri_ssm']).to eq descriptive.licenses.map(&:uri)
    end

    it 'sets the reuse_allowed field' do
      expect(indexed['reuse_allowed_ssi']).to_not be_blank
    end
  end
end
