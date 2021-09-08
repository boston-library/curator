# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/autoloadable'
require_relative './exceptions/shared/inheritance'

RSpec.describe Curator::Configuration do
  subject { described_class.new }

  %i(ark_manager_api_url authority_api_url avi_processor_url solr_url
     default_ark_params indexable_settings fedora_credentials default_remote_service_timeout_opts default_remote_service_pool_opts).each do |m|
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
          namespace_id: 'ARK_MANAGER_DEFAULT_NAMESPACE',
          oai_namespace_id: 'ARK_MANAGER_OAI_NAMESPACE',
          url_base: 'ARK_MANAGER_DEFAULT_BASE_URL'
        }.each do |k, v|
          expect(ark_config[k]).to eq ENV[v]
        end
      end
    end

    describe 'fedora_credentials' do
      let(:fedora_config) { subject.fedora_credentials }
      it 'returns a hash of values' do
        { fedora_username: 'FEDORA_USERNAME',
          fedora_password: 'FEDORA_PASSWORD'
        }.each do |k, v|
          expect(fedora_config[k]).to eq ENV[v]
        end
      end
    end

    describe 'default_remote_service_pool_opts' do
      let(:remote_service_pool_opts) { subject.default_remote_service_pool_opts }
      it 'return a hash of values' do
        %i(size timeout).each do |k|
          expect(remote_service_pool_opts[k]).to be_a_kind_of(Integer)
        end
      end
    end

    describe 'default_remote_service_timeout_opts' do
      let(:remote_service_timeout_opts) { subject.default_remote_service_timeout_opts }
      it 'return a hash of values' do
        %i(connect read write keep_alive).each do |k|
          expect(remote_service_timeout_opts[k]).to be_a_kind_of(Integer)
        end
      end
    end
  end
end
