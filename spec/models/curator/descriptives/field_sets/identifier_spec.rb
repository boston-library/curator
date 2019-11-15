# frozen_string_literal: true

require 'rails_helper'
require_relative '../../shared/descriptives/field_set'
RSpec.describe Curator::Descriptives::Identifier, type: :model do
  subject { create(:curator_descriptives_identifier) }
  it_behaves_like 'field_set'

  describe 'attributes' do
    it { is_expected.to respond_to(:label, :type, :invalid) }

    describe 'validations' do
      it { is_expected.to validate_presence_of(:type) }
      it { is_expected.to validate_presence_of(:label) }
      it { is_expected.to validate_inclusion_of(:type).
                          in_array(Curator::Descriptives::IDENTIFIER_TYPES) }
    end

    describe 'attr_json settings' do
      pending
    end
  end
end
