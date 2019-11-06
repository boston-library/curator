# frozen_string_literal: true

RSpec.shared_examples 'mappable' do
  it { is_expected.to have_many(:desc_terms).
                      inverse_of(:mappable).
                      class_name('Curator::Mappings::DescTerm').
                      dependent(:destroy) }
end
