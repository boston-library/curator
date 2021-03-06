# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'

RSpec.describe Curator::Filestreams::FileSet, type: :model do
  subject { build(:curator_filestreams_file_set) }

  it_behaves_like 'file_set'

  describe 'Associations' do
    it { is_expected.to belong_to(:file_set_of).
        inverse_of(:file_sets).
        class_name('Curator::DigitalObject').
        required }
  end
end
