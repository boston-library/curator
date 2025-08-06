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

    let(:iiif_manifest_url) { 'https://ark.digitalcommonwealth.org/ark:/50959/4f16g0150/manifest' }

    it 'expects the result to be successful' do
      expect(subject).to be_truthy
      expect(subject).to be_a_kind_of(Hash)
      expect(subject).to_not be_blank
    end
  end
end
