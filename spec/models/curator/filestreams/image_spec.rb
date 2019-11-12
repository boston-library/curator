# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/filestreams/file_set'

RSpec.describe Curator::Filestreams::Image, type: :model do
  subject { create(:curator_filestreams_image) }

  it_behaves_like 'file_set'

  describe 'Associations' do

    it { is_expected.to belong_to(:file_set_of).
                        inverse_of(:image_file_sets).
                        class_name('Curator::DigitalObject').
                        required }

  end
end
