# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::DescriptiveFieldSets::LocationUrlModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new).with(1).argument.and_keywords(:usage, :access, :note) }

  skip 'instance' do
  end
end
