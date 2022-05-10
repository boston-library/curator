# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::DescriptiveFieldSets::RelatedSeriesModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new).with(1).argument }

  skip 'instance' do
    subject { described_class.new(series) }

    let!(:series) { Faker::Lorem.words.join(' ') }
    let!(:sub_series) { Faker::Lorem.join(' ') }
    let!(:sub_sub_series) { Faker::Lorem.join(' ') }
    let!(:related_type) { related_type_lookup(:series) }

    let!(:related_item_series) { Curator::DescriptiveFieldSets::RelatedItemModsPresenter.new(related_type, title_label: series) }
    let!(:related_item_sub_series) { Curator::DescriptiveFieldSets.RelatedItemModsPresenter.new(related_type, title_label: sub_series) }
    let!(:related_item_sub_sub_series) { Curator::DescriptiveFieldSets.RelatedItemModsPresenter.new(related_type, title_label: sub_sub_series) }

    it { is_expected.to respond_to(:related_item, :sub_series, :type, :xlink, :display_label, :title_info).with(0).arguments }
    it { is_expected.to respond_to(:sub_series=).with(1).argument }
  end
end
