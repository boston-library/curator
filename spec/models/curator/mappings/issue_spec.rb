# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Mappings::Issue, type: :model do
  subject { create(:curator_mappings_issue) }

  it { is_expected.to have_db_column(:digital_object_id).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_column(:issue_of_id).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_index(:digital_object_id).unique(true) }
  it { is_expected.to have_db_index(:issue_of_id) }
  it { is_expected.to have_db_index([:digital_object_id, :issue_of_id]).unique(true) }

  it { is_expected.to validate_uniqueness_of(:digital_object_id) }

  it { is_expected.to validate_uniqueness_of(:issue_of_id).
                      scoped_to(:digital_object_id) }

  describe 'Associations' do
    it { is_expected.to belong_to(:digital_object).
                        inverse_of(:issue_mapping).
                        class_name('Curator::DigitalObject').
                        required }

    it { is_expected.to belong_to(:issue_of).
                        inverse_of(:issue_mapping_for).
                        class_name('Curator::DigitalObject').
                        required }
  end
end
