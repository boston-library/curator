# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Metastreams::WorkflowUpdaterService, type: :service do
  before(:all) do
    @workflow ||= build(:curator_metastreams_workflow, :draft)
    @digital_object ||= create(:curator_digital_object, administrative: @administrative)
    @workflowable_updated_at = @digital_object.updated_at
    @update_attributes ||= {
      publishing_state: :review
    }
    VCR.use_cassette('/services/metastreams/workflow/update', record: :new_episodes) do
      @success, @result = described_class.call(@digital_object.workflow, json_data: @update_attributes)
    end
  end

  describe '#call' do
    specify { expect(@success).to be_truthy }

    describe ':result' do
      subject { @result }

      specify { expect(subject).to be_valid }
      specify { expect(subject.workflowable.ark_id).to eq(@digital_object.ark_id) }
      specify { expect(subject.workflowable.updated_at).to be >= @workflowable_updated_at }

      it 'expects the attributes to have been updated' do
        expect(subject.publishing_state).to eq(@update_attributes[:publishing_state].to_s)
      end
    end
  end
end
