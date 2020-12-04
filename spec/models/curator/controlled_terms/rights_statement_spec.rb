# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/reindex_descriptable'
require_relative '../shared/controlled_terms/access_condition'
# NOTE: No authority delegations/ cannnicable shared examples in this class is by design

RSpec.describe Curator::ControlledTerms::RightsStatement, type: :model do
  it_behaves_like 'nomenclature'

  it_behaves_like 'access_condition'

  describe 'Associations' do
    it { is_expected.to have_many(:rights_statement_of).
        inverse_of(:rights_statement).
        class_name('Curator::Metastreams::Descriptive').
        with_foreign_key(:rights_statement_id).
        dependent(:destroy) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:uri) }
  end

  describe 'Callbacks' do
    it_behaves_like 'reindex_descriptable' do
      let(:test_term) { create(:curator_metastreams_descriptive).rights_statement }
    end
  end
end
