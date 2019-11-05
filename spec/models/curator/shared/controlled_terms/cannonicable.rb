# frozen_string_literal: true

RSpec.shared_examples 'cannonicable', type: :model do
  describe 'AUTH_NAME_KEY private constant' do
    it 'expects AUTH_NAME_KEY to have the proper value set' do
      expect(described_class.const_get(:AUTH_NAME_KEY)).to be('http://www.w3.org/2000/01/rdf-schema#label')
    end
  end

  describe '.cannonical_json_format' do
    let(:skos_auth) { described_class.find_by(code: 'lcsh') }
    let(:jsonld_auth) { described_class.find_by(code: 'aat') }

    it 'expects the correct response from authority instance' do
      expect(subject.cannonical_json_format).to be_nil
      expect(skos_auth.cannonical_json_format).to be('.skos.json')
      expect(jsonld_auth.cannonical_json_format).to be('.jsonld')
    end
  end

  describe '#fetch_canonical_name' do
    let!(:authority) { described_class.find_by(code: 'lcsh') }

    it 'expects #fetch_canonical_name to be called on :before_validate' do
      expect(authority.name).to be_a_kind_of(String)
      authority.name = nil
      expect(authority.send(:should_fetch_cannonical_name?)).to be_truthy
      VCR.use_cassette('controlled_terms/authority_cannonicable') do
        expect { authority.valid? }.to change(authority, :name).
        from(nil).
        to(be_a_kind_of(String))
      end
    end
  end
end
