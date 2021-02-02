# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::ApplicationController, type: :controller do
  let(:test_controller) { described_class.new }
  let(:request_ip) { '12.34.56.78' }

  before(:each) do
    test_controller.request = ActionDispatch::TestRequest.new('REMOTE_ADDR' => request_ip)
  end

  describe '#user_for_paper_trail' do
    it 'sets the request IP as the user value' do
      expect(test_controller.send(:user_for_paper_trail)).to eq(request_ip)
    end
  end
end
