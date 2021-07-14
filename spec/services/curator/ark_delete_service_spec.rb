# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/remote_service'

RSpec.describe Curator::ArkDeleteService, type: :service do
  subject { described_class }

  it_behaves_like 'remote_service'

  it 'expects the .base_url to eq the Curator.config.ark_manager_api_url' do
    expect(subject.base_url).to eq(Curator.config.ark_manager_api_url)
  end

  describe '#call' do
    subject do
      VCR.use_cassette('services/institutions/destroy_ark') do
        described_class.call(ark_id)
      end
    end

    let(:ark_url) { "#{Curator.config.ark_manager_api_url}/api/v2/arks/#{ark_id}" }
    let(:ark_id) { 'bpl-dev:3n206530d' }

    # NOTE: Uncomment the following to refresh the VCR cassete
    # let(:mintable) { build(:curator_institution, ark_id: nil) }
    # let(:ark_id) do
    #   VCR.use_cassette('services/institutions/ark_for_destroy') do
    #      Curator::MinterService.call(mintable.ark_params)
    #   end
    # end

    let(:verify_result) do
      VCR.use_cassette('services/institutions/verify_ark_destroyed') do
        HTTP.get(ark_url)
      end
    end

    specify { expect(subject).to be_truthy }
    specify { expect(ark_id).to be_truthy.and be_a_kind_of(String) }
    specify { expect(verify_result).to be_truthy }

    it 'expects the ark to have been destroyed in the ark manager' do
      expect(verify_result.code).to eq(404)
    end
  end
end
