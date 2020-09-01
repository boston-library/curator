# frozen_string_literal: true

require 'rails_heper'
require_relative './shared/remote_service'

RSpec.describe Curator::MinterService, type: :service do
  it_behaves_like 'remote_service'
end
