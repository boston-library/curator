# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::ControlledTerms::ResourceTypeModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:wrap_multiple).with(0..1).arguments.and_keywords(:resource_type_manuscript) }
  it { is_expected.to respond_to(:new).with(1).argument.and_keywords(:resource_type_manuscript) }

  skip 'instance' do
    subject { described_class.new(resource_type, resource_type_manuscript: true) }
    let!(:resource_type) { Curator::ControlledTerms::ResourceType.order(Arel.sql('RANDOM()')).first }
  end
end
