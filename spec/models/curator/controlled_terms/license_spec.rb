# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/reindex_descriptable'
require_relative '../shared/controlled_terms/access_condition'
# NOTE: No authority delegations/ canonicable shared examples in this class is by design

RSpec.describe Curator::ControlledTerms::License, type: :model do
  it_behaves_like 'nomenclature'

  it_behaves_like 'access_condition'

  describe 'Associations' do
    it { is_expected.to have_many(:licensees).
                        inverse_of(:license).
                        class_name('Curator::Metastreams::Descriptive').
                        with_foreign_key(:license_id).
                        dependent(:destroy) }
  end

  describe 'Validations' do
    it { is_expected.to allow_values(nil, '').for(:uri) }
  end

  describe 'Callbacks' do
    it_behaves_like 'reindex_descriptable' do
      let(:test_term) { create(:curator_metastreams_descriptive).license }
    end
  end
end
