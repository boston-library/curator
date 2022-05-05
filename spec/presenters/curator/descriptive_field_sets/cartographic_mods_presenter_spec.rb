# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::DescriptiveFieldSets::CartographicModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new).with_keywords(:projection, :bounding_box, :area_type, :coordinates, :scale) }

  skip 'instance' do
  end
end
