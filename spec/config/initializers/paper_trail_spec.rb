# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaperTrail::Config do
  subject { PaperTrail.config }

  it 'has the correct defaults' do
    expect(subject.has_paper_trail_defaults[:on].sort).to eq(%i(destroy touch update))
    expect(subject.has_paper_trail_defaults[:ignore].sort).to eq(%i(created_at lock_version updated_at))
  end
end
