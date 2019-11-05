# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'

RSpec.describe Curator::ControlledTerms::Name, type: :model do
  it_behaves_like 'nomenclature'
end
