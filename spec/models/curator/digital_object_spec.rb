# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/mintable.rb'
module Curator
  RSpec.describe DigitalObject, type: :model do
    let!(:digital_object) { create(:curator_digital_object) }

    subject { digital_object }

    it_behaves_like 'mintable'
  end
end
