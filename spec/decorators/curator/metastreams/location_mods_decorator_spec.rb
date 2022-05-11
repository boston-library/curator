# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/curator_decorator'

RSpec.describe Curator::Metastreams::LocationModsDecorator, type: :decorators do
  let!(:descriptive) { create(:curator_metastreams_descriptive) }

  describe 'Base Behavior' do
    it_behaves_like 'curator_decorator' do
      let(:decorator) { described_class.new(descriptive) }
    end
  end
end
