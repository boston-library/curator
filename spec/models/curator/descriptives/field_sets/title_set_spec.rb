# frozen_string_literal: true

require 'rails_helper'
require_relative '../../shared/descriptives/field_set'
RSpec.describe Curator::Descriptives::TitleSet, type: :model do
  subject { create(:curator_descriptives_title_set) }
  it_behaves_like 'field_set'

  describe 'attributes' do
    it { is_expected.to respond_to(:primary, :other) }

    it { is_expected.to validate_presence_of(:primary) }
  end
end
