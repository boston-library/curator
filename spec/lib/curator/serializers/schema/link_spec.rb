# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::Link, type: :lib_serializers do
  let!(:collection) { create(:curator_collection) }
  let!(:link_string) { "/search/#{collection.ark_id}" }

  describe 'link by method' do
    subject { described_class.new(key: :link) }

    let!(:collection_dbl) { double(collection) }
    before(:each) do
      allow(collection_dbl).to receive(:link).and_return(link_string)
    end

    it 'expects the link method on the record to serialize to the correct value' do
      expect(subject.serialize(collection_dbl)).to eq(link_string)
    end

    include_examples 'conditional_attributes' do
      let(:serializable_record) { double(collection) }
      let(:key) { :link }
      let(:method) { key }
      before(:each) do
        allow(serializable_record).to receive(key).and_return(link_string)
      end
    end
  end

  describe 'link by proc' do
    subject { described_class.new(key: :my_key, method: link_proc) }

    let!(:link_proc) { ->(record) { "/search/#{record.ark_id}" } }

    it 'expects the link proc for the record to serialize to the correct value' do
      expect(subject.serialize(collection)).to eq(link_string)
    end

    include_examples 'conditional_attributes' do
      let(:serializable_record) { collection }
      let(:key) { :link }
      let(:method) { link_proc }
    end

    describe 'with additional params' do
      subject { described_class.new(key: :my_link_key, method: link_proc_with_params) }

      let(:link_params) { { host: 'https://mytesthost.org' } }
      let!(:link_proc_with_params) { ->(record, serializer_params) { "#{serializer_params.fetch(:host, 'http://localhost:3000')}/search/#{record.ark_id}" } }

      it 'expects the link proc to serialize the correct value based on the arguments used' do
        expect(subject.serialize(collection, link_params)).to eql("#{link_params[:host]}#{link_string}")
        expect(subject.serialize(collection)).to eql("http://localhost:3000#{link_string}")
      end
    end
  end
end
