# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/mintable.rb'

RSpec.describe Curator::Institution, type: :model do
  subject { create(:curator_institution) }

  it_behaves_like 'mintable'
end
