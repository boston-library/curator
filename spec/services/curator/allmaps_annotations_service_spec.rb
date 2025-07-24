# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/remote_service'

RSpec.describe Curator::AllmapsAnnotationsService, type: :service do
  subject { described_class }

  it_behaves_like 'remote_service'

  it 'expects the .base_url to eq the Curator.config.allmaps_annotations_url' do
    expect(subject.base_url).to eq(Curator.config.allmaps_annotations_url)
  end

  describe '#call' do
    subject do
      VCR.use_cassette('services/allmaps_annotations_service') do
        described_class.call(iiif_manifest_url)
      end
    end

    # TODO: prefer to use a manifest URL that returns a non-empty response from Allmaps dev site,
    #       but this should still pass
    let(:iiif_manifest_url) { '' }

    it 'expects the result to be successful' do
      expect(subject).to be_truthy
      expect(subject).to be_a_kind_of(Hash)
    end
  end
end
