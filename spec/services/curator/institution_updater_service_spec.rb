# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::InstitutionUpdaterService, type: :service do
  subject { create(:curator_institution) }

  let!(:location) { create(:curator_controlled_terms_geographic) }
  let!(:thumbnail_path) { file_fixture('image_thumbnail_300.jpg') }

  let!(:update_attributes) do
    {
      abstract: "#{subject.asbtract} [UPDATED]",
      url: Faker::Internet.unique.url(host: 'example-updated-institution.org'),
      image_thumbnail_300: {
        io: File.open(thumbnail_path.to_s, 'rb'),
        filename: thumbnail_path.basename.to_s
      },
      location: {
        label: location.label,
        id_from_auth: location.id_from_auth
        coordinates: location.coordinates,
        authority_code: location.authority_code,
        area_type: location.area_type
      },
      host_collection_attributes: [
        { name: 'Host Collection One' },
        { name: 'Host Collection Two' }
      ]
    }

    # before(:all) do
    #   VCR.use_cassete('')
    # end

    describe '#call result' do
    end
  end
end
