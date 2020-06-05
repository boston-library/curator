# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Metastreams::DescriptiveUpdaterService, type: :service do
  pending 'Awaiting implementation'

  before(:all) do
    @digital_object ||= create(:curator_digital_object)
    @update_attributes ||= load_json_fixture('digital_object_2', 'digital_object').dig('metastreams', 'descriptive')
    VCR.use_cassette('services/metastreams/descriptive/update', record: :new_episodes) do
      @success, @result = described_class.call(@digital_object.descriptive, json_data: @update_attributes || {})
    end
  end

  describe '#call' do
    specify { expect(@success).to be_truthy }

    describe ':result' do
      subject { @result }

      it {awesome_print subject}

      specify { expect(subject).to be_valid }
      specify { expect(subject.descriptable.ark_id).to eq(@digital_object.ark_id) }
    end
  end
end
