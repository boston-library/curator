require 'rails_helper'
require_relative './shared/mintable.rb'
module Curator
  RSpec.describe DigitalObject, type: :model do
    before(:all) do
      @digital_object = create(:curator_digital_object)
    end
    subject{ @digital_object }

    it_behaves_like 'mintable'
  end
end
