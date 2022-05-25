# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::DescriptiveFieldSets::RelatedSeriesModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new).with(1).argument }

  describe 'instance' do
    subject { described_class.new(related_item_series) }

    let!(:series) { Faker::Lorem.words.join(' ') }
    let!(:sub_series) { Faker::Lorem.words.join(' ') }
    let!(:sub_sub_series) { Faker::Lorem.words.join(' ') }
    let!(:related_type) { related_type_lookup(:series) }

    let!(:related_item_series) { Curator::DescriptiveFieldSets::RelatedItemModsPresenter.new(related_type, title_label: series) }
    let!(:related_item_sub_series) { Curator::DescriptiveFieldSets::RelatedItemModsPresenter.new(related_type, title_label: sub_series) }
    let!(:related_item_sub_sub_series) { Curator::DescriptiveFieldSets::RelatedItemModsPresenter.new(related_type, title_label: sub_sub_series) }
    let!(:delegated_methods) { %i(type xlink display_label title_info) }

    it { is_expected.to respond_to(:related_item, :sub_series, :type, :xlink, :display_label, :title_info).with(0).arguments }
    it { is_expected.to respond_to(:sub_series=).with(1).argument }

    it 'expects methods to be delegated to #related_item' do
      delegated_methods.each do |delegated_method|
        expect(subject).to delegate_method(delegated_method).to(:related_item).allow_nil
      end
    end

    context 'with sub_series' do
      subject do
        series = described_class.new(related_item_series)
        series.sub_series = described_class.new(related_item_sub_series)
        series
      end

      it 'expects sub_series to be an instance of described_class' do
        expect(subject.sub_series).to be_an_instance_of(described_class)
        expect(subject.sub_series).to respond_to(:related_item, :sub_series, :type, :xlink, :display_label, :title_info).with(0).arguments
        expect(subject.sub_series).to respond_to(:sub_series=).with(1).argument
        expect(subject.sub_series.related_item).to be_an_instance_of(Curator::DescriptiveFieldSets::RelatedItemModsPresenter)
        expect(subject.sub_series.sub_series).to be(nil)
      end

      it 'expects the sub_series to delegate methods to its #related_item' do
        delegated_methods.each do |delegated_method|
          expect(subject.sub_series).to delegate_method(delegated_method).to(:related_item).allow_nil
        end
      end
    end

    context 'with_sub_sub_series' do
      subject do
        series = described_class.new(related_item_series)
        series.sub_series = described_class.new(related_item_sub_series)
        series.sub_series.sub_series = described_class.new(related_item_sub_sub_series)
        series
      end

      it 'expects sub_series#sub_series to be an instance of described_class' do
        expect(subject.sub_series.sub_series).to be_an_instance_of(described_class)
        expect(subject.sub_series.sub_series).to respond_to(:related_item, :sub_series, :type, :xlink, :display_label, :title_info).with(0).arguments
        expect(subject.sub_series.sub_series).to respond_to(:sub_series=).with(1).argument
        expect(subject.sub_series.sub_series.related_item).to be_an_instance_of(Curator::DescriptiveFieldSets::RelatedItemModsPresenter)
        expect(subject.sub_series.sub_series.sub_series).to be(nil)
      end

      it 'expects the sub_series to delegate methods to its #related_item' do
        delegated_methods.each do |delegated_method|
          expect(subject.sub_series.sub_series).to delegate_method(delegated_method).to(:related_item).allow_nil
        end
      end
    end
  end
end
