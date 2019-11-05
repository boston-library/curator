# frozen_string_literal: true

RSpec.shared_examples 'cannonicable', type: :model do
  describe 'AUTH_NAME_KEY private constant' do
    it 'expects AUTH_NAME_KEY to have the proper value set' do
      expect(described_class.const_get(:NOM_LABEL_KEY)).to be('http://www.w3.org/2004/02/skos/core#prefLabel')
    end
  end

  describe '#fetch_canonical_label' do
    let!(:nomenclature) { described_class.where.not(authority_id: nil).first }

    it 'expects #fetch_canonical_name to be called on :before_validate' do
      expect(nomenclature.label).to be_a_kind_of(String)
      nomenclature.label = nil
      expect(nomenclature.send(:label_required?)).to be_truthy
      expect(nomenclature.send(:should_fetch_cannonical_label?)).to be_truthy

      VCR.use_cassette('controlled_terms/nomenclature_cannonicable') do
        expect { nomenclature.valid? }.to change(nomenclature, :label).
        from(nil).
        to(be_a_kind_of(String))
      end
    end
  end
end
