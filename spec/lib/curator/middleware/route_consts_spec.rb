# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Middleware::RouteConsts do
  subject { described_class }

  it { is_expected.to be_const_defined(:JSON_CONSTRAINT) }
  it { is_expected.to be_const_defined(:XML_CONSTRAINT)}
  it { is_expected.to be_const_defined(:NOMENCLATURE_TYPES) }
  it { is_expected.to be_const_defined(:FILE_SET_TYPES) }

  describe 'Constants' do
    describe 'JSON_CONSTRAINT' do
      subject { described_class.const_get(:JSON_CONSTRAINT) }

      it { is_expected.to be_a_kind_of(Proc).and be_lambda }
    end

    describe 'XML_CONSTRAINT' do
      subject { described_class.const_get(:XML_CONSTRAINT) }

      it { is_expected.to be_a_kind_of(Proc).and be_lambda }
    end

    describe 'NOMENCLATURE_TYPES' do
      subject { described_class.const_get(:NOMENCLATURE_TYPES) }

      let(:expected_val) { Curator.controlled_terms.nomenclature_types.map(&:underscore) }

      it { is_expected.to be_a_instance_of(Array).and be_frozen }
      it { is_expected.to eq(expected_val) }
    end

    describe 'FILE_SET_TYPES' do
      subject { described_class.const_get(:FILE_SET_TYPES) }

      let(:expected_val) { Curator.filestreams.file_set_types.map(&:downcase).freeze }

      it { is_expected.to be_a_instance_of(Array).and be_frozen }
      it { is_expected.to eq(expected_val) }
    end
  end
end
