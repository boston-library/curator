# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::SchemaBuilders::Mods do
  subject { described_class }

  it { is_expected.to be_const_defined(:ROOT_ATTRIBUTES) }
  it { is_expected.to be <= Curator::Serializers::SchemaBuilders::XML }

  it 'expects :ROOT_ATTRIBUTES to be a hash and be frozen' do
    expect(subject.const_get(:ROOT_ATTRIBUTES)).to be_a_kind_of(Hash).and be_frozen
  end
end
