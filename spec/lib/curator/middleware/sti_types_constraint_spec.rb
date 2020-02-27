# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Middleware::StiTypesConstraint do
  let!(:example_sti_list) { %w(foos todos) }

  describe 'instance' do
    subject { described_class.new(example_sti_list) }

    let(:expected_pattern) { Regexp.union(example_sti_list)  }

    it_behaves_like 'constraint'

    it { is_expected.to respond_to(:sti_type_matcher) }

    it 'expects #pattern to eq :expected_pattern' do
      expect(subject.sti_type_matcher).to eq(expected_pattern)
    end

    describe '#matches?' do
      let(:valid_request) { double(params: { type: 'foos' }) }
      let(:invalid_request) { double(params: { type: 'bars' }) }

      it { is_expected.to be_matches(valid_request) }
      it { is_expected.not_to be_matches(invalid_request) }
    end
  end
end
