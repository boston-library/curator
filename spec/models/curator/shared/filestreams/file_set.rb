# frozen_string_literal: true

require_relative '../optimistic_lockable.rb'
require_relative '../timestampable.rb'
require_relative '../mintable.rb'

RSpec.shared_examples 'file_set', type: :model do
  it { is_expected.to be_a_kind_of(Curator::Filestreams::FileSet) }

  it_behaves_like 'optimistic_lockable'
  it_behaves_like 'timestampable'
  it_behaves_like 'mintable'

  it { is_expected.to have_db_column(:file_set_type).
                      of_type(:string).
                      with_options(null: false) }

  it { is_expected.to have_db_column(:file_name_base).
                      of_type(:string).
                      with_options(null: false) }

  it { is_expected.to have_db_column(:position).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_column(:pagination).
                      of_type(:jsonb).
                      with_options(default: '{}', null: false) }

  it { is_expected.to have_db_column(:file_set_of_id).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_index(:file_set_of_id) }
  it { is_expected.to have_db_index(:file_set_type) }
  it { is_expected.to have_db_index(:position) }
  it { is_expected.to have_db_index(:pagination) }

  it { is_expected.to validate_presence_of(:file_set_type) }
  it { is_expected.to validate_presence_of(:file_name_base) }
end
