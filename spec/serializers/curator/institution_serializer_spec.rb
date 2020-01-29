# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/inherited_serializers'

RSpec.describe Curator::InstitutionSerializer, type: :serializers do
  let!(:record) { create(:curator_institution, :with_location, :with_metastreams) }
  let!(:adapter_key) { :json }

  it_behaves_like 'curator_serializer'

  describe 'Serializing Collection' do
    let!(:records) { create_list(:curator_institution, 3, :with_location, :with_metastreams) }
  end
end
