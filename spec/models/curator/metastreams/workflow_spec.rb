# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/optimistic_lockable'
require_relative '../shared/timestampable'
require_relative '../shared/archivable'

RSpec.describe Curator::Metastreams::Workflow, type: :model do
  subject { build(:curator_metastreams_workflow) }

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
                        of_type(:enum).
                        with_options(default: 'draft') }

    it { is_expected.to have_db_column(:processing_state).
                        of_type(:enum).
                        with_options(default: 'initialized') }

    it { is_expected.to have_db_column(:ingest_origin).
                        of_type(:string).
                        with_options(null: false) }

    it { is_expected.to have_db_index(:publishing_state) }
    it { is_expected.to have_db_index(:processing_state) }
    it { is_expected.to have_db_index([:workflowable_type, :workflowable_id]).unique(true) }

    it { is_expected.to define_enum_for(:publishing_state).
                        with_values(draft: 'draft', review: 'review', published: 'published').
                        backed_by_column_of_type(:enum) }

    it { is_expected.to define_enum_for(:processing_state).
                        with_values(initialized: 'initialized', derivatives: 'derivatives', complete: 'complete').
                        backed_by_column_of_type(:enum) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:ingest_origin) }

    it { is_expected.to validate_uniqueness_of(:workflowable_id).
                        scoped_to(:workflowable_type) }
    it { is_expected.to allow_values(*described_class.publishing_states.keys).for(:publishing_state) }

    it { is_expected.to allow_values(*described_class.processing_states.keys).for(:processing_state) }

    it { is_expected.to allow_values(*(Curator::Metastreams.valid_base_types + Curator::Metastreams.valid_filestream_types)).for(:workflowable_type) }
  end

  describe 'State Transitions' do
    let!(:institution) { build(:curator_institution) }
    let!(:collection) { build(:curator_collection) }
    let!(:digital_object) { build(:curator_digital_object) }
    let!(:file_set) { build(:curator_filestreams_image, file_set_of: digital_object) }
    let!(:publishable_object_workflows) do
      [
        institution.workflow,
        collection.workflow,
        digital_object.workflow
      ]
    end

    let!(:processible_object_workflows) do
      [
        digital_object.workflow,
        file_set.workflow
      ]
    end

    describe '#publishing_state' do
      subject { publishable_object_workflows }

      it { is_expected.to all(have_state(:draft).on(:publishing_state)) }
      it { is_expected.to all(transition_from(:draft).to(:published).on_event(:publish).on(:publishing_state)) }

      it 'should not allow the #start_review event to be triggered' do
        subject.each do |obj|
          expect(obj).to_not allow_event(:start_review).on(:publishing_state)
        end
      end
    end

    describe '#processing_state' do
      subject { processible_object_workflows }

      it { is_expected.to all(have_state(:initialized).on(:processing_state)) }

      it 'should not allow the transition to complete initially' do
        subject.each do |obj|
          expect(obj).to_not allow_event(:mark_complete).on(:processing_state)
        end
      end
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:workflowable).
                        inverse_of(:workflow).
                        required }
  end
end
