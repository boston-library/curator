# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/mintable.rb'

RSpec.describe Curator::DigitalObject, type: :model do
  subject { create(:curator_digital_object) }

  it_behaves_like 'mintable'
end
