# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Metastreams::LocationModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new).with_keywords(:physical_location_name, :holding_simple, :uri_list) }

  skip 'instance' do
    subject { described_class.new(physical_location) }

    let!(:digital_object) { create(:curator_digital_object) }
    let!(:physical_location_name) { Faker::University.name }
    let!(:holding_simple_attrs) { { sub_location: Faker::Educator.campus, shelf_locator: 'Box 002' } }
    let!(:holding_simple) { Curator::Metastreams::HoldingSimpleModsPresenter.new(**holding_simple_attrs) }
    let!(:uri) { Curator::DescriptiveFieldSets::LocationUrlModsPresenter.new(digital_object.ark_identifier.label, usage: 'primary', access: 'object in context')}
    let!(:uri_list) { Array.wrap(uri) }
  end
end
