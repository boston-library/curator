# frozen_string_literal: true

require 'rails_helper'
require_relative '../../shared/descriptives/field_set'
RSpec.describe Curator::Descriptives::Cartographic, type: :model do
  subject { create(:curator_descriptives_cartographic) }
  it_behaves_like 'field_set'

  describe 'attributes' do
    it { is_expected.to respond_to(:scale, :projection) }

    describe 'attr_json settings' do
      pending
    end
  end
end
