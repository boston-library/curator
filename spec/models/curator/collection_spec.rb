# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/mintable'
require_relative './shared/metastreamable'
require_relative './shared/optimistic_lockable'
require_relative './shared/timestampable'
require_relative './shared/archivable'
require_relative './shared/mappings/has_exemplary_file_set'

RSpec.describe Curator::Collection, type: :model do
  subject { create(:curator_collection) }

  it_behaves_like 'mintable'

  describe 'Database' do
    it_behaves_like 'optimistic_lockable'
    it_behaves_like 'timestampable'
    it_behaves_like 'archivable'

    it { is_expected.to have_db_column(:institution_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_index(:institution_id) }

    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:abstract).of_type(:text).with_options(default: '') }
  end

  describe 'Associations' do
    it_behaves_like 'metastreamable_basic'
    it_behaves_like 'has_exemplary_file_set'

    it { is_expected.to belong_to(:institution).
      inverse_of(:collections).
      class_name('Curator::Institution').required }

    it { is_expected.to have_many(:admin_set_objects).
        inverse_of(:admin_set).
        class_name('Curator::DigitalObject').with_foreign_key(:admin_set_id).dependent(:destroy) }

    it { is_expected.to have_many(:collection_members).
        inverse_of(:collection).
        class_name('Curator::Mappings::CollectionMember').dependent(:destroy) }
  end
end
