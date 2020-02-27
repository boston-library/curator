# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/constraint'

RSpec.describe Curator::Middleware::ArkOrIdConstraint do
  subject { described_class }

  it { is_expected.to be_const_defined(:ID_REGEX) }
  it { is_expected.to be_const_defined(:ARK_REGEX) }

  describe 'instance' do
    subject { described_class.new }

    let(:expected_pattern) { Regexp.union(described_class.const_get(:ID_REGEX), described_class.const_get(:ARK_REGEX)) }

    it_behaves_like 'constraint'

    it { is_expected.to respond_to(:pattern) }

    it 'expects #pattern to eq :expected_pattern' do
      expect(subject.pattern).to eq(expected_pattern)
    end

    describe '#matches?' do
      let(:valid_request) { double(params: { id: 1 }) }
      let(:invalid_request) { double(params: { id: 'FOO' }) }

      it { is_expected.to be_matches(valid_request) }
      it { is_expected.not_to be_matches(invalid_request) }

      context 'ark_id as :id' do
        let(:valid_request) { double(params: { id: 'valid:abcdef123' }) }
        let(:valid_request2) { double(params: { id: 'i-can_have-separators:abcdef123' }) }
        let(:invalid_request) { double(params: { id: 'not-enough-characters-after-me:abcdef' }) }

        it { is_expected.to be_matches(valid_request) }
        it { is_expected.to be_matches(valid_request2) }
        it { is_expected.not_to be_matches(invalid_request) }
      end
    end
  end
end
