# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/remote_service'

RSpec.describe Curator::ControlledTerms::AuthorityService, type: :service do
  subject { described_class }

  it_behaves_like 'remote_service'

  it 'expects the .base_url to eq the Curator.config.authority_api_url' do
    expect(subject.base_url).to eq(Curator.config.authority_api_url)
  end

  describe '#call' do
    let(:auth_data) do
      VCR.use_cassette('services/controlled_terms/authority_service') do
        described_class.call(path: 'authorities')
      end
    end

    it 'fetches the data from the API' do
      expect(auth_data).to be_a_kind_of(Array)
      expect(auth_data).to_not be_blank
    end
  end
end
