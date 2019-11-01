# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/mintable.rb'
module Curator
  RSpec.describe Institution, type: :model do
    let!(:institution) { create(:curator_institution) }

    subject { institution }

    it_behaves_like 'mintable'
  end
end
