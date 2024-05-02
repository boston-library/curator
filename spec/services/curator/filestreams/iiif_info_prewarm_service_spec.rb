# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/remote_service'

RSpec.describe Curator::Filestreams::IIIFInfoPrewarmService, type: :service do
  subject { described_class }

  it_behaves_like 'remote_service'

  it 'expects the .base_url to eq the Curator.config.iiif_server_url' do
    expect(subject.base_url).to eq(Curator.config.iiif_server_url)
  end

  describe '#call' do
    subject do
      VCR.use_cassette('services/filestreams/iiif_info_prewarm') do
        described_class.call(ark_id)
      end
    end

    let(:ark_id) { 'bpl-dev:8049g5699' }
    let(:iiif_info_url) { "#{Curator.config.iiif_server_url}/iiif/2/#{ark_id}/info.json" }

    it 'expects the result to be successful' do
      expect(subject).to be_truthy
      expect(subject).to be_a_kind_of(String).and include(iiif_info_url)
    end
  end
end