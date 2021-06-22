# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/versionable'

RSpec.describe Curator::Mappings::CollectionMember, type: :model do
  subject { build(:curator_mappings_collection_member, digital_object: digital_object) }

  let!(:digital_object) { create(:curator_digital_object) }

  it { is_expected.to have_db_column(:digital_object_id).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_column(:collection_id).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_index(:digital_object_id) }
  it { is_expected.to have_db_index(:collection_id) }
  it { is_expected.to have_db_index([:digital_object_id, :collection_id]).unique(true) }

  it { is_expected.to validate_uniqueness_of(:collection_id).
                      scoped_to(:digital_object_id) }

  describe 'Associations' do
    it { is_expected.to belong_to(:collection).
                        inverse_of(:collection_members).
                        class_name('Curator::Collection').
                        required }

    it { is_expected.to belong_to(:digital_object).
                        inverse_of(:is_member_of_collection).
                        class_name('Curator::DigitalObject').
                        touch(true).
                        required }
  end

  it_behaves_like 'versionable_mapping'
end
