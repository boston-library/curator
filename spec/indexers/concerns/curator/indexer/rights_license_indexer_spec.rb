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
    let(:descriptive) { create(:curator_metastreams_descriptive) }
    let(:descriptable_object) { descriptive.digital_object }
    let(:indexed) { indexer.map_record(descriptable_object) }

    it 'sets the rights field' do
      expect(indexed['rights_ss']).to eq [descriptive.rights]
    end

    it 'sets the restrictions_on_access field' do
      expect(indexed['restrictions_on_access_ss']).to eq [descriptive.access_restrictions]
    end

    it 'sets the license field' do
      expect(indexed['license_ss']).to eq descriptive.license.label
    end

    it 'sets the license_uri field' do
      expect(indexed['license_uri_ss']).to eq descriptive.license.uri
    end

    it 'sets the rights_statement field' do
      expect(indexed['rightsstatement_ss']).to eq descriptive.rights_statement.label
    end

    it 'sets the rights_statement_uri field' do
      expect(indexed['rightsstatement_uri_ss']).to eq descriptive.rights_statement.uri
    end

    it 'sets the reuse_allowed field' do
      expect(indexed['reuse_allowed_ssi']).to_not be_blank
    end
  end
end
