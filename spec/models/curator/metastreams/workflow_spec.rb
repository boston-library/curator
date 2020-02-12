# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/optimistic_lockable'
require_relative '../shared/timestampable'
require_relative '../shared/archivable'

RSpec.describe Curator::Metastreams::Workflow, type: :model do
  subject { create(:curator_metastreams_workflow) }

  describe 'Database' do
    it_behaves_like 'optimistic_lockable'
    it_behaves_like 'timestampable'
    it_behaves_like 'archivable'

    it { is_expected.to have_db_column(:workflowable_type).
                        of_type(:string).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:workflowable_id).
                        of_type(:integer).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:publishing_state).
                        of_type(:integer).
                        with_options(default: 'draft') }

    it { is_expected.to have_db_column(:processing_state).
                       of_type(:integer) }

    it { is_expected.to have_db_column(:ingest_origin).
                        of_type(:string).
                        with_options(null: false) }

    it { is_expected.to have_db_index(:publishing_state) }
    it { is_expected.to have_db_index(:processing_state) }
    it { is_expected.to have_db_index([:workflowable_type, :workflowable_id]).unique(true) }

    it { is_expected.to define_enum_for(:publishing_state).
                        with_values(draft: 0, review: 1, published: 2).
                        backed_by_column_of_type(:integer) }

    it { is_expected.to define_enum_for(:processing_state).
                        with_values(derivatives: 0, complete: 1).
                        backed_by_column_of_type(:integer) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:ingest_origin) }

    it { is_expected.to validate_uniqueness_of(:workflowable_id).
                        scoped_to(:workflowable_type) }

    it { is_expected.to allow_values(*(Curator::Metastreams.valid_base_types + Curator::Metastreams.valid_filestream_types)).for(:workflowable_type) }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:workflowable).
                        inverse_of(:workflow).
                        required }
  end
end
