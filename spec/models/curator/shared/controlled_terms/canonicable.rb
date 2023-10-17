# frozen_string_literal: true

RSpec.shared_examples 'canonicable', type: :model do
  describe '#set_canonical_label' do
    let!(:nomenclature) { build(factory_key_for(described_class), term_data: term_data, authority: authority) }

    it 'expects #set_canonical_label to be called on :before_validate on :create' do
      nomenclature.label = nil
      expect(nomenclature.send(:should_set_canonical_label?)).to be_truthy
      expect { nomenclature.valid? }.to change(nomenclature, :label).
      from(nil).
      to(be_a_kind_of(String))
    end
  end
end
