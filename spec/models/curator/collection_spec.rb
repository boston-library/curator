# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/mintable.rb'
module Curator
  RSpec.describe Collection, type: :model do
    let!(:collection) { create(:curator_collection) }

    subject { collection }

    it_behaves_like 'mintable'
  end
end
