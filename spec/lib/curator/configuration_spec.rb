# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/autoloadable'
require_relative './exceptions/shared/inheritance'

RSpec.describe Curator::Configuration do
  subject { described_class.new }

  %i(ark_manager_api_url authority_api_url avi_processor_url solr_url
     default_ark_params indexable_settings).each do |m|
    it { is_expected.to respond_to(m) }
    it { is_expected.to respond_to("#{m}=") }
  end

  describe 'default values' do
    it 'uses ENV vars' do
      %i(ark_manager_api_url authority_api_url avi_processor_url solr_url).each do |m|
        expect(subject.public_send(m)).to eq ENV[m.to_s.upcase]
      end
    end

    describe 'indexable_settings' do
      it 'returns an instance of Curator::IndexableSettings' do
        expect(subject.indexable_settings).to be_an_instance_of(Curator::IndexableSettings)
      end
    end

    describe 'default_ark_params' do
      let(:ark_config) { subject.default_ark_params }
      it 'returns a hash of ark values' do
        { namespace_ark: 'ARK_NAMESPACE',
          namespace_id: 'ARK_NAMESPACE_ID',
          url_base: 'ARK_URL_BASE'
        }.each do |k, v|
          expect(ark_config[k]).to eq ENV[v]
        end
      end
    end
  end
end