require 'rails_helper'
require_relative './shared/mintable.rb'
module Curator
  RSpec.describe Institution, type: :model do
    before(:all) do
      @institution = create(:curator_institution)
    end
    subject { @institution }

    it_behaves_like 'mintable'
  end
end
