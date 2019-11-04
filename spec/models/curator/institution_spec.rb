# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/mintable.rb'

RSpec.describe Curator::Institution, type: :model do
  subject { create(:curator_institution) }

  it { is_expected.to have_db_column(:name).of_type(:string) }
  it { is_expected.to have_db_column(:url).of_type(:string) }
  it { is_expected.to have_db_column(:abstract).of_type(:text) }

  it_behaves_like 'mintable'

  describe 'Associations' do
    it { is_expected.to belong_to(:location).
      inverse_of(:institution_locations).
      class_name('Curator::ControlledTerms::Geographic').optional }

    it { is_expected.to have_many(:host_collections).
      inverse_of(:institution).class_name('Curator::Mappings::HostCollection') }

    it { is_expected.to have_many(:collections).
      inverse_of(:institution).class_name('Curator::Collection').dependent(:destroy) }

    it { is_expected.to have_many(:collection_admin_set_objects).
      through(:collections).source(:admin_set_objects) }
  end
end
