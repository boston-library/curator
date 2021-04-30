# frozen_string_literal: true

RSpec.shared_examples 'archivable', type: :model do
  skip 'Keeping this example around in case we decide to use soft deletion' do
    it { is_expected.to have_db_column(:archived_at).of_type(:datetime) }
    it { is_expected.to have_db_index(:archived_at) }
  end
end
