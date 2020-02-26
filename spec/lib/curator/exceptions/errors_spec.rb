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

    %i(BadRequest Unauthorized RouteNotFound RecordNotFound NotAcceptable MethodNotAllowed ServerError).each do |serializable_error_const|
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

        it_behaves_like 'serializable_error'
        it_behaves_like 'model_error'
      end
    end
  end
end
