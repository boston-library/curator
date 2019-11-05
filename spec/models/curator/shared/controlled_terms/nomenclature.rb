# frozen_string_literal: true

require_relative '../optimistic_lockable.rb'
require_relative '../timestampable.rb'

RSpec.shared_examples 'nomenclature', type: :model do

  it { is_expected.to be_a_kind_of(Curator::ControlledTerms::Nomenclature) }

  it_behaves_like 'optimistic_lockable'
  it_behaves_like 'timestampable'

  it { is_expected.to have_db_column(:type).of_type(:string).with_options(null: false ) }
  it { is_expected.to have_db_column(:term_data).of_type(:jsonb).with_options(null: false ) }
  it { is_expected.to have_db_column(:authority_id).of_type(:integer) }

  it { is_expected.to have_db_index(:authority_id) }
  it { is_expected.to have_db_index(:type) }
  it { is_expected.to have_db_index(:term_data) }
  it { is_expected.to have_db_index("((term_data ->> 'id_from_auth'::text))") }

end
