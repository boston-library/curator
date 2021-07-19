# frozen_string_literal: true

RSpec.shared_examples 'local_id_finder', type: :model do
  # Requires expected_scope_sql stub in block when including
  describe '#local_id_finder scope' do
    subject { described_class }

    it { is_expected.to respond_to(:local_id_finder).with(scope_args.count).arguments }

    it 'expects the the scope as sql to match :expected_scope_sql' do
      expect(subject.local_id_finder(*scope_args).to_sql).to match(expected_scope_sql)
    end
  end
end
