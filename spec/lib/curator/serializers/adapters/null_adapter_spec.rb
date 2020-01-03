# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::NullAdapter, type: :lib_serializers do
  subject { described_class.new }

  let!(:digital_object) { build(:curator_digital_object) }
  let!(:arbitrary_class) do
    Class.new do
      def initialize(*)
        @attrs = {}
      end
    end
  end

  it 'expects #serializable_hash to return an empty hash regardless of what is passed in' do
    expect(subject.serializable_hash).to be_a_kind_of(Hash).and be_empty
    expect(subject.serializable_hash(nil)).to be_a_kind_of(Hash).and be_empty
    expect(subject.serializable_hash(digital_object)).to be_a_kind_of(Hash).and be_empty
    expect(subject.serializable_hash(arbitrary_class.new)).to be_a_kind_of(Hash).and be_empty
  end

  it 'expects #render to to return an empty hash regardless of what is passed in' do
    expect(subject.render).to be_a_kind_of(Hash).and be_empty
    expect(subject.render(nil)).to be_a_kind_of(Hash).and be_empty
    expect(subject.render(digital_object)).to be_a_kind_of(Hash).and be_empty
    expect(subject.render(arbitrary_class.new)).to be_a_kind_of(Hash).and be_empty
  end
end
