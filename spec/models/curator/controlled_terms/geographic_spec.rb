# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/cannonicable'

RSpec.describe Curator::ControlledTerms::Geographic, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'
  # TODO: Currently the only compatible models stubbed out are the ones loaded from the seeds(authority, genre). Look at the JSON fixtures and see if there's a way to stub the other nomenclatures that will be compatible.
  # it_behaves_like 'cannonicable'
end
