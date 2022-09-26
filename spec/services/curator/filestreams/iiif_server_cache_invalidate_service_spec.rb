# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/remote_service'

RSpec.describe Curator::Filestreams::IIIFServerCacheInvalidateService, type: :service do
  subject { described_class }

  it_behaves_like 'remote_service'

  it 'expects the .base_url to eq the Curator.config.iiif_server_url' do
    expect(subject.base_url).to eq(Curator.config.iiif_server_url)
  end

  describe '#call' do
    subject do
      VCR.use_cassette('services/filestreams/iiif_cache_invalidate') do
        described_class.call(ark_id)
      end
    end

    let(:ark_id) { 'bpl-dev:3n206530d' }

    it 'expects the result to be successful' do
      expect(subject).to be_truthy
      expect(subject).to be_a_kind_of(Hash).and have_key(:location)
    end
  end
end
