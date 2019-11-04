# frozen_string_literal: true

RSpec.shared_examples 'optimistic_lockable', type: :model do
  it { is_expected.to have_db_column(:lock_version).of_type(:integer) }
end
