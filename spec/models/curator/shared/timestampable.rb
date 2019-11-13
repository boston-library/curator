# frozen_string_literal: true

RSpec.shared_examples 'timestampable', type: :model do
  it { is_expected.to  have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to  have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
end
