# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/inheritance'

RSpec.describe Curator::Exceptions do
  describe 'controller_errors' do
    %i(UnknownFormat UnknownSerializer UnknownResourceType UndeletableResource).each do |general_exception_const|
      it { is_expected.to be_const_defined(general_exception_const) }

      describe "Curator::Exceptions::#{general_exception_const}" do
        subject { described_class.const_get(general_exception_const) }

        specify { expect(subject).to be <= Curator::Exceptions::CuratorError }
      end
    end

    %i(BadRequest Unauthorized RouteNotFound RecordNotFound NotAcceptable MethodNotAllowed UnprocessableEntity ServerError).each do |serializable_error_const|
      it { is_expected.to be_const_defined(serializable_error_const) }

      describe "Curator::Exception::#{serializable_error_const}" do
        let(:described_const) { described_class.const_get(serializable_error_const) }
        it_behaves_like 'serializable_error'
      end
    end
  end

  describe 'model_errors' do
    %i(InvalidRecord).each do |model_error_const|
      it { is_expected.to be_const_defined(model_error_const) }

      describe "Curator::Exception::#{model_error_const}" do
        let(:described_const) { described_class.const_get(model_error_const) }

        it_behaves_like 'model_error_wrapper'
      end
    end
  end

  describe 'remote_service_errors' do
    %i(SolrUnavailable AuthorityApiUnavailable ArkManagerApiUnavailable RemoteServiceError).each do |remote_error_const|
      it { is_expected.to be_const_defined(remote_error_const) }

      describe "Curator::Exception::#{remote_error_const}" do
        subject { described_class.const_get(remote_error_const) }

        specify { expect(subject).to be <= Curator::Exceptions::CuratorError }
      end
    end

    describe 'Curator::Exceptions::RemoteServiceError' do
      subject { Curator::Exceptions::RemoteServiceError.new }

      it { is_expected.to respond_to(:json_response, :code) }
    end
  end

  describe 'indexer_errors' do
    it { is_expected.to be_const_defined(*[IndexerError, IndexerBadRequestError, GeographicIndexerError]) }

    describe "Curator::Exceptions::IndexerError" do
      subject { described_class.const_get(IndexerError) }

      specify { expect(subject).to be <= Curator::Exceptions::CuratorError }

      it 'is expected to have a default message' do
        expect(subject.new.message).to eq('An error occcured indexing a record!')
      end
    end

    describe 'Curator::Exceptions::IndexerBadRequestError' do
      subject { described_class.const_get(IndexerBadRequestError) }

      specify { expect(subject).to be <= Curator::Exceptions::IndexerError }

      it 'is expected to respond to response' do
        expect(subject.new).to respond_to(:response)
      end
    end

    describe 'Curator::Exceptions::IndexerBadRequestError' do
      subject { described_class.const_get(IndexerBadRequestError) }

      specify { expect(subject).to be <= Curator::Exceptions::IndexerError }

      it 'is expected to respond to #response' do
        expect(subject.new).to respond_to(:response)
      end
    end

    describe 'Curator::Exceptions::GeographicIndexerError' do
      subject { described_class.const_get(GeographicIndexerError) }

      specify { expect(subject).to be <= Curator::Exceptions::IndexerError }

      it 'is expected to respond to #geo_auth_url' do
        expect(subject.new).to respond_to(:geo_auth_url)
      end
    end
  end
end
