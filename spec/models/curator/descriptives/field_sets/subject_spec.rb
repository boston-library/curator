# frozen_string_literal: true

require 'rails_helper'
require_relative '../../shared/descriptives/field_set'
RSpec.describe Curator::Descriptives::Subject, type: :model do
  subject { create(:curator_descriptives_subject) }
  it_behaves_like 'field_set'
end
