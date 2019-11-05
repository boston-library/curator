# frozen_string_literal: true

require_relative '../optimistic_lockable.rb'
require_relative '../timestampable.rb'

RSpec.shared_examples 'file_set', type: :model do
  it { is_expected.to be_a_kind_of(Curator::Filestreams::FileSet) }

  it_behaves_like 'optimistic_lockable'
  it_behaves_like 'timestampable'
end
