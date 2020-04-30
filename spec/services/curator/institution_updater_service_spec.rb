# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::InstitutionUpdaterService, type: :service do
  before(:all) do
    @institution ||= create(:curator_institution)
    @location ||= create(:curator_controlled_terms_geographic)
    @thumbnail_path ||= file_fixture('image_thumbnail_300.jpg')
    @update_attributes ||= {
      abstract: "#{@institution.abstract} [UPDATED]",
      url: Faker::Internet.unique.url(host: "#{@institution.name.downcase.split(' ').join('-')}-updated-institution.org"),
      image_thumbnail_300: {
        io: File.open(@thumbnail_path.to_s, 'rb'),
        filename: @thumbnail_path.basename.to_s
      },
      location: {
        label: @location.label,
        id_from_auth: @location.id_from_auth,
        coordinates: @location.coordinates,
        authority_code: @location.authority_code,
        area_type: @location.area_type
      },
      host_collections_attributes: [
        { name: 'Host Collection One' },
        { name: 'Host Collection Two' }
      ]
    }
    VCR.use_cassette('institutions/update', record: :new_episodes) do
      @success, @result = described_class.call(@institution, json_data: @update_attributes)
    end
  end

  describe '#call' do
    specify { expect(@success).to be_truthy }

    describe ':result' do
      subject { @result }

      specify { expect(subject.id).to eq(@institution.id) }
      specify { expect(subject.ark_id).to eq(@institution.ark_id) }

      it { is_expected.to be_valid }

      it 'expects the attributes to have been updated' do
        [:url, :abstract].each do |attr|
          expect(subject.public_send(attr)).to eq(@update_attributes[attr])
        end
      end

      it 'expects there to be an updated #image_thumbnail_300' do
        expect(subject.image_thumbnail_300).to be_attached
        expect(subject.image_thumbnail_300.filename).to eq(@update_attributes[:image_thumbnail_300][:filename])
        expect(subject.image_thumbnail_300.content_type).to eq('image/jpeg')
      end

      it 'expects the #location to have been updated' do
        expect(subject.location).to be_truthy
        [:label, :id_from_auth, :coordinates, :authority_code, :area_type].each do |loc_attr|
          expect(subject.location.public_send(loc_attr)).to eq(@update_attributes[:location][loc_attr])
        end
      end

      it 'expects the #host_collections to have been updated' do
        expect(subject.host_collections.count).to eq(2)
        expect(subject.host_collections.pluck(:name)).to include('Host Collection One', 'Host Collection Two')
      end
    end
  end
end
