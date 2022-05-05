# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Metastreams::HoldingSimpleModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new).with_keywords(:sub_location, :shelf_locator) }

  describe Curator::Metastreams::HoldingSimpleModsPresenter::CopyInformation do
    subject { described_class }

    it { is_expected.to be <= Struct }
    it { is_expected.to respond_to(:new) }
    # NOTE: structs attributes have to be tested this(below) way and won't work with respond_to(...).with_keywords(...)
    it 'is expected to have the following member attributes' do
      expect(subject.members).to include(:sub_location, :shelf_locator)
    end

    skip 'instance' do
    end
  end

  skip 'instance' do
  end
end
