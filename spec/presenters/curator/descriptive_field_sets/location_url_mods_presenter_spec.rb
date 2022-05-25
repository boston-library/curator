# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::DescriptiveFieldSets::LocationUrlModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new).with(1).argument.and_keywords(:usage, :access, :note) }

  describe 'instance' do
    let!(:digital_object) { create(:curator_digital_object) }
    let!(:ark_uri_identifier) { digital_object.ark_identifier }
    let!(:ark_preview_identifier) { digital_object.ark_preview_identifier }
    let!(:ark_iiif_uri_identifier) { digital_object.ark_iiif_manifest_identifier }

    context 'with :ark_uri_identifier' do
      subject { described_class.new(ark_uri_identifier.label, **uri_attributes) }

      let!(:uri_attributes) { { usage: 'primary', access: 'object in context' } }

      it { is_expected.to respond_to(:url, :usage, :access, :note).with(0).arguments }

      it 'is expected to have the correct values set' do
        expect(subject.url).to eql(ark_uri_identifier.label)
        expect(subject.usage).to eql(uri_attributes[:usage])
        expect(subject.access).to eql(uri_attributes[:access])
        expect(subject.note).to be_nil
      end
    end

    context 'with :ark_preview_identifier' do
      subject { described_class.new(ark_preview_identifier.label, **uri_attributes) }

      let!(:uri_attributes) { { access: 'preview' } }

      it { is_expected.to respond_to(:url, :usage, :access, :note).with(0).arguments }

      it 'is expected to have the correct values set' do
        expect(subject.url).to eql(ark_preview_identifier.label)
        expect(subject.access).to eql(uri_attributes[:access])
        expect(subject.usage).to be_nil
        expect(subject.note).to be_nil
      end
    end

    context 'with :ark_iiif_uri_identifier' do
      subject { described_class.new(ark_iiif_uri_identifier.label, note: ark_iiif_uri_identifier.type) }

      it 'is expected to have the correct values set' do
        expect(subject.url).to eql(ark_iiif_uri_identifier.label)
        expect(subject.note).to eql(ark_iiif_uri_identifier.type)
        expect(subject.access).to be_nil
        expect(subject.usage).to be_nil
      end
    end
  end
end
