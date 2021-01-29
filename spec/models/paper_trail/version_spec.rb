# frozen_string_literal: true

require 'rails_helper'

# for testing Curator-specific mods to default PaperTrail::Version migration
RSpec.describe PaperTrail::Version, type: :model do
  subject { described_class.new }

  describe 'Database' do
    it { is_expected.to have_db_column(:object).
        of_type(:json) }

    it { is_expected.to have_db_column(:item_subtype).
        of_type(:string).
        with_options(null: true) }

    it { is_expected.to have_db_column(:object_changes).
        of_type(:json) }
  end
end
