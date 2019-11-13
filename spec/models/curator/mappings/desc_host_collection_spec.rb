# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Mappings::DescHostCollection, type: :model do
  subject { create(:curator_mappings_desc_host_collection) }

  it { is_expected.to have_db_column(:descriptive_id).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_column(:host_collection_id).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_index(:descriptive_id) }
  it { is_expected.to have_db_index(:host_collection_id) }
  it { is_expected.to have_db_index([:descriptive_id, :host_collection_id]).unique(true) }

  it { is_expected.to validate_uniqueness_of(:host_collection_id).
                      scoped_to(:descriptive_id) }

  describe 'Associations' do
    it { is_expected.to belong_to(:descriptive).
                        inverse_of(:desc_host_collections).
                        class_name('Curator::Metastreams::Descriptive').
                        required }

    it { is_expected.to belong_to(:host_collection).
                        inverse_of(:desc_host_collections).
                        class_name('Curator::Mappings::HostCollection').
                        required }
  end
end
