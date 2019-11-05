# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'

RSpec.describe Curator::ControlledTerms::Name, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'
end
