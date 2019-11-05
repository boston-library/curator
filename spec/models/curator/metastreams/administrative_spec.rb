# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/optimistic_lockable'
require_relative '../shared/timestampable'

RSpec.describe Curator::Metastreams::Administrative, type: :model do
  it_behaves_like 'optimistic_lockable'
  it_behaves_like 'timestampable'
end
