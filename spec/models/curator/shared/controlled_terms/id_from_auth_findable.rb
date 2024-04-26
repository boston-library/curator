# frozen_string_literal: true

RSpec.shared_examples 'id_from_auth_findable', type: :model do
  describe 'Class Methods' do
    subject { described_class }

    it { is_expected.to respond_to(:find_id_from_auth, :find_id_from_auth!).with(1).argument }
  end
end