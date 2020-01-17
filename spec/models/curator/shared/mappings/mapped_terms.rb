# frozen_string_literal: true

RSpec.shared_examples 'mapped_term', type: :model do
  it { is_expected.to have_many(:desc_terms).
                      inverse_of(:mapped_term).
                      class_name('Curator::Mappings::DescTerm').
                      with_foreign_key(:mapped_term_id).
                      dependent(:destroy) }
end
