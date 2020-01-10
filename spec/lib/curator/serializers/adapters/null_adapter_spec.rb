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

  it 'is expected to have a nil schema' do
    expect(subject.schema).to be_nil
  end

  it 'expects #serializable_hash to return an empty hash depending on what is passed in' do
    expect(subject.serializable_hash).to be_a_kind_of(Hash).and be_empty
    expect(subject.serializable_hash(nil)).to be_a_kind_of(Hash).and be_empty
    expect(subject.serializable_hash(digital_object)).to be_a_kind_of(Hash).and be_empty
    expect(subject.serializable_hash(arbitrary_class.new)).to be_a_kind_of(Hash).and be_empty
  end

  it 'expects #render to to return an empty hash depending on what is passed in' do
    expect(subject.render).to be_a_kind_of(Hash).and be_empty
    expect(subject.render(nil)).to be_a_kind_of(Hash).and be_empty
    expect(subject.render(digital_object)).to be_a_kind_of(Hash).and be_empty
    expect(subject.render(arbitrary_class.new)).to be_a_kind_of(Hash).and be_empty
  end

  describe 'when for_relation is passed as true in serializer_params' do
    let!(:serializer_params) { { for_relation: true } }
    
    describe 'when iterable' do
      let!(:inst_with_collections) { create(:curator_institution, collection_count: 2) }
      let!(:collections) { inst_with_collections.collections }
      let!(:arbitrary_array) { Array.new(3) { arbitrary_class.new } }
      it 'expects #serialized_hash to return and empty_array if records are iterable' do
        expect(subject.serializable_hash(collections, serializer_params)).to be_a_kind_of(Array).and be_empty
        expect(subject.serializable_hash(arbitrary_array, serializer_params)).to be_a_kind_of(Array).and be_empty
      end

      it 'expects #render to return and empty_array if records are iterable' do
        expect(subject.render(collections, serializer_params)).to be_a_kind_of(Array).and be_empty
        expect(subject.render(arbitrary_array, serializer_params)).to be_a_kind_of(Array).and be_empty
      end
    end
  end
end
