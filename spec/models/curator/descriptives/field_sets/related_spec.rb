# frozen_string_literal: true

require 'rails_helper'
require_relative '../../shared/descriptives/field_set'
RSpec.describe Curator::Descriptives::Related, type: :model do
  subject { create(:curator_descriptives_related) }
  it_behaves_like 'field_set'

  describe 'attributes' do
    it { is_expected.to respond_to(:constituent, :other_format, :referenced_by_url, :references_url, :review_url) }

    describe 'attr_json settings' do
      pending
    end
  end
end
