# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/remote_service'

RSpec.describe Curator::MinterService, type: :service do
  subject { described_class }

  it_behaves_like 'remote_service'

  it 'expects the .base_url to eq the Curator.config.ark_manager_api_url' do
    expect(subject.base_url).to eq(Curator.config.ark_manager_api_url)
  end

  describe 'Minting #ark_id' do
    before(:all) do
      @mintable ||= build(:curator_institution, ark_id: nil)

      VCR.use_cassette('services/institutions/minter') do
        @ark_id = described_class.call(@mintable.ark_params)
      end
    end

    it 'expects the #ark_id to have been generated' do
      expect(@ark_id).to be_a_kind_of(String)
      expect(@ark_id).to start_with('commonwealth')
    end
  end
end
