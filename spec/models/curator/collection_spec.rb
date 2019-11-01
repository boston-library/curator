# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/mintable.rb'
module Curator
  RSpec.describe Collection, type: :model do
    before(:each) do
      @collection = create(:curator_collection)
    end
    subject { @collection }

    it_behaves_like 'mintable'
  end
end
