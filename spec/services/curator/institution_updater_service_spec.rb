# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::InstitutionUpdaterService, type: :service do
  before(:all) do
    @institution ||= create(:curator_institution)
    @host_collection_to_remove ||= create(:curator_mappings_host_collection, institution: @institution)
    @location ||= create(:curator_controlled_terms_geographic)

    @update_attributes ||= {
      abstract: "#{@institution.abstract} [UPDATED]",
      url: Faker::Internet.unique.url(host: "#{@institution.name.downcase.split(' ').join('-')}-updated-institution.org"),
      location: {
        label: @location.label,
        id_from_auth: @location.id_from_auth,
        coordinates: @location.coordinates,
        authority_code: @location.authority_code,
        bounding_box: @location.bounding_box,
        area_type: @location.area_type
      },
      host_collections_attributes: [
        { name: 'Host Collection One' },
        { name: 'Host Collection Two' },
        { id: @host_collection_to_remove.id, _destroy: '1' }
      ]
    }

    @success, @result = described_class.call(@institution, json_data: @update_attributes)
  end

  describe '#call' do
    specify { expect(@success).to be_truthy }

    describe ':result' do
      subject { @result }

      specify { expect(subject).to be_valid }
      specify { expect(subject.ark_id).to eq(@institution.ark_id) }

      it 'expects the attributes to have been updated' do
        [:url, :abstract].each do |attr|
          expect(subject.public_send(attr)).to eq(@update_attributes[attr])
        end
      end

      it 'expects the #location to have been updated' do
        expect(subject.location).to be_valid
        [:label, :id_from_auth, :coordinates, :authority_code, :area_type].each do |loc_attr|
          expect(subject.location.public_send(loc_attr)).to eq(@update_attributes[:location][loc_attr])
        end
      end

      it 'expects the #host_collections to have been updated' do
        expect(subject.host_collections.count).to eq(2)
        expect(subject.host_collections.pluck(:name)).to include('Host Collection One', 'Host Collection Two')
        expect(subject.host_collections.pluck(:name)).not_to include(@host_collection_to_remove.name)
      end
    end
  end
end
