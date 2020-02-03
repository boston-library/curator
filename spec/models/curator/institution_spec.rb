# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/mintable'
require_relative './shared/metastreamable'
require_relative './shared/optimistic_lockable'
require_relative './shared/timestampable'
require_relative './shared/archivable'

RSpec.describe Curator::Institution, type: :model do
  subject { create(:curator_institution) }

  it_behaves_like 'mintable'

  describe 'Database' do
    it_behaves_like 'optimistic_lockable'
    it_behaves_like 'timestampable'
    it_behaves_like 'archivable'

    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:url).of_type(:string) }
    it { is_expected.to have_db_column(:abstract).of_type(:text).with_options(default: '') }
  end

  describe 'Validations' do
    it { is_expected.to allow_values('', nil, 'http://myinstitution.org').for(:url) }
    it { is_expected.not_to allow_value('not a website string').for(:url) }
  end

  describe 'Associations' do
    it_behaves_like 'metastreamable_basic'

    it { is_expected.to belong_to(:location).
      inverse_of(:institution_locations).
      class_name('Curator::ControlledTerms::Geographic').optional }

    it { is_expected.to have_many(:host_collections).
      inverse_of(:institution).class_name('Curator::Mappings::HostCollection').dependent(:destroy) }

    it { is_expected.to have_many(:collections).
      inverse_of(:institution).class_name('Curator::Collection').dependent(:destroy) }

    it { is_expected.to have_many(:collection_admin_set_objects).
      through(:collections).source(:admin_set_objects) }
  end
end
