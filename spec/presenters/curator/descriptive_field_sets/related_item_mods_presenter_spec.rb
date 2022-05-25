# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::DescriptiveFieldSets::RelatedItemModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new).with(1).argument.and_keywords(:title_label, :xlink, :display_label) }

  describe 'instance' do
    let!(:related_obj) { create(:curator_descriptives_related) }

    context 'host' do
      subject { described_class.new(related_type, title_label: host_collection.name) }

      let!(:related_type) { related_type_lookup(:host) }
      let!(:host_collection) { create(:curator_mappings_host_collection) }

      it { is_expected.to respond_to(:type, :xlink, :title_info, :display_label).with(0).arguments }

      it 'expects the instance to have the correct values' do
        expect(subject.type).to eql(related_type)
        expect(subject.title_info).to be_an_instance_of(Curator::DescriptiveFieldSets::Title)
        expect(subject.title_info.label).to eql(host_collection.name)
        expect(subject.xlink).to be(nil)
        expect(subject.display_label).to be(nil)
      end
    end

    context 'constituent' do
      subject { described_class.new(related_type, title_label: related_obj.constituent) }

      let!(:related_type) { related_type_lookup(:constituent) }

      it { is_expected.to respond_to(:type, :xlink, :title_info, :display_label).with(0).arguments }

      it 'expects the instance to have the correct values' do
        expect(subject.type).to eql(related_type)
        expect(subject.title_info).to be_an_instance_of(Curator::DescriptiveFieldSets::Title)
        expect(subject.title_info.label).to eql(related_obj.constituent)
        expect(subject.xlink).to be(nil)
        expect(subject.display_label).to be(nil)
      end
    end

    context 'series' do
      subject { described_class.new(related_type, title_label: series) }

      let!(:series) { Faker::Lorem.words.join(' ') }
      let!(:related_type) { related_type_lookup(:series) }

      it { is_expected.to respond_to(:type, :xlink, :title_info, :display_label).with(0).arguments }

      it 'expects the instance to have the correct values' do
        expect(subject.type).to eql(related_type)
        expect(subject.title_info).to be_an_instance_of(Curator::DescriptiveFieldSets::Title)
        expect(subject.title_info.label).to eql(series)
        expect(subject.xlink).to be(nil)
        expect(subject.display_label).to be(nil)
      end
    end

    context 'review' do
      subject { described_class.new(related_type, xlink: review_url) }

      let!(:review_url) { related_obj.review_url.first }
      let!(:related_type) { related_type_lookup(:review) }

      it { is_expected.to respond_to(:type, :xlink, :title_info, :display_label).with(0).arguments }

      it 'expects the instance to have the correct values' do
        expect(subject.type).to eql(related_type)
        expect(subject.xlink).to eql(review_url)
        expect(subject.title_info).to be(nil)
        expect(subject.display_label).to be(nil)
      end
    end

    context 'referenced_by' do
      subject { described_class.new(related_type, xlink: referenced_by.url, display_label: referenced_by.label) }

      let!(:referenced_by) { related_obj.referenced_by.first }
      let!(:related_type) { related_type_lookup(:referenced_by) }

      it { is_expected.to respond_to(:type, :xlink, :title_info, :display_label).with(0).arguments }

      it 'expects the instance to have the correct values' do
        expect(subject.type).to eql(related_type)
        expect(subject.xlink).to eql(referenced_by.url)
        expect(subject.display_label).to eql(referenced_by.label)
        expect(subject.title_info).to be(nil)
      end
    end

    context 'references' do
      subject { described_class.new(related_type, xlink: reference_url) }

      let!(:related_type) { related_type_lookup(:references) }
      let!(:reference_url) { related_obj.references_url.first }

      it { is_expected.to respond_to(:type, :xlink, :title_info, :display_label).with(0).arguments }

      it 'expects the instance to have the correct values' do
        expect(subject.type).to eql(related_type)
        expect(subject.xlink).to eql(reference_url)
        expect(subject.display_label).to be(nil)
        expect(subject.title_info).to be(nil)
      end
    end

    context 'other_format' do
      subject { described_class.new(related_type, title_label: other_format) }

      let!(:related_type) { related_type_lookup(:other_format) }
      let!(:other_format) { related_obj.other_format.first }

      it { is_expected.to respond_to(:type, :xlink, :title_info, :display_label).with(0).arguments }

      it 'expects the instance to have the correct values' do
        expect(subject.type).to eql(related_type)
        expect(subject.title_info).to be_an_instance_of(Curator::DescriptiveFieldSets::Title)
        expect(subject.title_info.label).to eql(other_format)
        expect(subject.xlink).to be(nil)
        expect(subject.display_label).to be(nil)
      end
    end
  end
end
