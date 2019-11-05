# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
# NOTE: No authority delegations in this class

RSpec.describe Curator::ControlledTerms::License, type: :model do
  it_behaves_like 'nomenclature'
end
