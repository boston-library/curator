# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Metastreams::AdministrativeUpdaterService, type: :service do
  before(:all) do
    @administrative ||= build(:curator_metastreams_administrative, :is_flagged, :non_havestable)
    @digital_object ||= create(:curator_digital_object, administrative: @administrative)
    @administratable_updated_at = @digital_object.updated_at
    @update_attributes ||= {
      flagged: false,
      description_standard: :local,
      harvestable: true,
      destination_site: ['commonwealth', 'bpl']
    }
    VCR.use_cassette('services/metastreams/administrative/update', record: :new_episodes) do
      @success, @result = described_class.call(@digital_object.administrative, json_data: @update_attributes)
    end
  end

  describe '#call' do
    specify { expect(@success).to be_truthy }

    describe ':result' do
      subject { @result }

      specify { expect(subject).to be_valid }
      specify { expect(subject.administratable.ark_id).to eq(@digital_object.ark_id) }
      specify { expect(subject.administratable.updated_at).not_to eq(@administratable_updated_at) }

      it 'expects the attributes to have been updated' do
        [:flagged, :harvestable].each do |attr|
          expect(subject.public_send(attr)).to eq(@update_attributes[attr])
        end
        expect(subject.description_standard).to eq(@update_attributes[:description_standard].to_s)
        expect(subject.destination_site).to match(@update_attributes[:destination_site])
      end
    end
  end
end
