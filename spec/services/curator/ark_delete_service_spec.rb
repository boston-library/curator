#frozen_string_literal: true

require 'rails_helper'
require_relative './shared/remote_service'

RSpec.describe Curator::ArkDeleteService, type: :service do
  subject { described_class }

  it_behaves_like 'remote_service'

  it 'expects the .base_url to eq the Curator.config.ark_manager_api_url' do
    expect(subject.base_url).to eq(Curator.config.ark_manager_api_url)
  end

  describe '#call' do
    before(:all) do
      @mintable ||= build(:curator_institution, ark_id: nil)

      VCR.use_cassette('services/institutions/destroy_ark') do
        @ark_id = Curator::MinterService.call(@mintable.ark_params)
      end
    end

    let(:ark_url) { "#{Curator.config.ark_manager_api_url}/api/v2/#{@ark_id}" }

    it 'expects the ark to ark been successfully deleted' do
      VCR.use_cassette('services/destroy_ark') do
        result = described_class.call(@ark_id)
        expect(result).to be_truthy
        verify_result = HTTP.get(ark_url)
        expect(verify_result.code).to be(404)
      end
    end
  end
end
