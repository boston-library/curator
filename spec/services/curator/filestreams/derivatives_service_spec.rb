# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/remote_service'

RSpec.describe Curator::Filestreams::DerivativesService, type: :service do
  subject { described_class }

  it_behaves_like 'remote_service'

  it 'expects the .base_url to eq the Curator.config.avi_processor_url' do
    expect(subject.base_url).to eq(Curator.config.avi_processor_api_url)
  end
end
