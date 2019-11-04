# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/mintable.rb'

RSpec.describe Curator::Collection, type: :model do
  subject { create(:curator_collection) }

  it { is_expected.to have_db_column(:name) }
  it { is_expected.to have_db_column(:abstract) }

  it_behaves_like 'mintable'


end
