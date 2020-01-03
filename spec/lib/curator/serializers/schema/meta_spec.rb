# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::Meta, type: :lib_serializers do
  let!(:meta_object) { create(:curator_institution, collection_count: collection_count) }
  let!(:collection_count) { 5 }

  it 'expects an error to be raised on #new if a method is not a block, lambda or proc' do
    expect { build_facet_inst(klass: described_class, key: :some_key, method: nil) }.to raise_error(RuntimeError, 'Method must be a proc, lamda or block!')
    expect { build_facet_inst(klass: described_class, key: :some_key, method: :some_method) }.to raise_error(RuntimeError, 'Method must be a proc, lamda or block!')
  end

  describe 'serializing meta' do
    subject { build_facet_inst(klass: described_class, key: :my_key, method: ->(record) { record.present? }) }

    it { is_expected.to be_include_value }

    describe 'with specific data' do
      subject { build_facet_inst(klass: described_class, key: meta_key, method: ->(record) { record.collections.count }) }

      let(:meta_key) { :collection_count }

      it 'expects #serialize to return the correct value' do
        expect(subject.serialize(meta_object)).to eq(collection_count)
      end

      it 'expects the resulting hash in the schema to be formatted correctly' do
        expect(serialize_facet_inst(subject, meta_object)).to be_a_kind_of(Hash).and include(meta_key => collection_count)
      end
    end

    describe 'with custom data' do
      subject { build_facet_inst(klass: described_class, key: meta_key, method: meta_proc) }

      let(:meta_key) { :collection_truncated_desc }
      let(:meta_params) { { range: 0..20 } }
      let(:meta_proc) { ->(record, serializer_params) { record.abstract[serializer_params[:range]] } }

      it 'expects #serialize to return the correct value' do
        expect(subject.serialize(meta_object, meta_params)).to eq(meta_object.abstract[0..20])
      end

      it 'expects the resulting hash in the schema to be formatted correctly' do
        expect(serialize_facet_inst(subject, meta_object, meta_params)).to be_a_kind_of(Hash).and include(meta_key => meta_object.abstract[0..20])
      end
    end
  end
end
