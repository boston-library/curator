# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::SolrUtil do
  describe '#solr_ready?' do
    it 'returns true if Solr is available' do
      expect(described_class).to be_solr_ready
    end

    it 'returns false if Solr is not available' do
      ClimateControl.modify SOLR_URL: 'http://127.0.0.1:9999/solr/wrong' do
        expect(described_class).not_to be_solr_ready
      end
    end
  end
end
