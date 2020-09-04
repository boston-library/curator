# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/remote_service'

RSpec.describe Curator::MinterService, type: :service do
  subject { described_class }

  it_behaves_like 'remote_service'
end
