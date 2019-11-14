# frozen_string_literal: true

require 'rails_helper'
require_relative '../../shared/descriptives/field_set'
RSpec.describe Curator::Descriptives::Note, type: :model do
  subject { create(:curator_descriptives_note) }
  it_behaves_like 'field_set'

  describe 'attributes' do
    it { is_expected.to respond_to(:label, :type) }

    it { is_expected.to validate_presence_of(:type) }
  end
end
