# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/autoloadable'
require_relative './exceptions/shared/inheritance'

RSpec.describe Curator::Exceptions do
  it_behaves_like 'autoloadable'

  it { is_expected.to be_const_defined(:CuratorError) }
  it { is_expected.to be_const_defined(:SerializableError) }
  it { is_expected.to be_const_defined(:ModelError) }

  describe Curator::Exceptions::CuratorError do
    it { is_expected.to be_a_kind_of(StandardError) }
  end

  describe Curator::Exceptions::SerializableError do
    it { is_expected.to be_a_kind_of(Curator::Exceptions::CuratorError) }

    it_behaves_like 'serializable_error' do
      let(:described_const) { described_class }
    end

    describe 'instance mmethod defaults' do
      subject { described_class.new }

      it 'expects attributes to have defaults' do
        expect(subject.title).to eql('Something went wrong')
        expect(subject.detail).to eql('We encountered unexpected error')
        expect(subject.status).to be(500)
        expect(subject.source).to be_a_kind_of(Hash).and be_empty
      end
    end
  end

  describe Curator::Exceptions::ModelError do
    it { is_expected.to be_a_kind_of(Curator::Exceptions::SerializableError) }

    it_behaves_like 'serializable_error' do
      let(:described_const) { described_class }
    end

    it_behaves_like 'model_error' do
      let(:described_const) { described_class }
    end
  end
end
