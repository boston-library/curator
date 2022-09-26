# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/remote_service'

RSpec.describe Curator::IIIFManifestInvalidateService, type: :service do
  subject { described_class }

  it_behaves_like 'remote_service'

  it 'expects the .base_url to eq the Curator.config.iiif_manifest_url' do
    expect(subject.base_url).to eq(Curator.config.iiif_manifest_url)
  end

  describe '#call' do
    subject do
      VCR.use_cassette('services/iiif_manifest_invalidate') do
        described_class.call(ark_id)
      end
    end

    let(:ark_id) { 'bpl-dev:6q182k915' }

    it 'expects the result to be successful' do
      expect(subject).to be_truthy
      expect(subject).to be_a_kind_of(Hash)
    end
  end
end
