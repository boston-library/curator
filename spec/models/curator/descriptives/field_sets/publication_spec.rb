# frozen_string_literal: true

require 'rails_helper'
require_relative '../../shared/descriptives/field_set'
RSpec.describe Curator::Descriptives::Publication, type: :model do
  subject { create(:curator_descriptives_publication) }
  it_behaves_like 'field_set'

  describe 'attributes' do
    it { is_expected.to respond_to(:edition_name, :edition_number, :volume, :issue_number) }

    describe 'attr_json settings' do
      pending
    end
  end
end
