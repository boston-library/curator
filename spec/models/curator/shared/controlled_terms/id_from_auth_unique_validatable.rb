# frozen_string_literal: true

RSpec.shared_examples 'id_from_auth_uniqueness_validatable', type: :model do
  describe 'Validations' do
    subject(:nomenclature) { build(factory_key_for(described_class), term_data: term_data, authority: authority) }

    it { is_expected.to be_valid }

    context 'when invalid' do
      let!(:expected_error_messgage_key) { :id_from_auth }
      let!(:expected_error_message) { "Id from auth #{term_data[:id_from_auth]} has already been taken for #{described_class}!" }

      before(:each) do
        create(factory_key_for(described_class), term_data: term_data, authority: authority)
        nomenclature.valid?
      end

      it { is_expected.not_to be_valid }

      it 'expects nomenclature to have errors' do
        expect(nomenclature.errors).to have_key(expected_error_messgage_key)
        expect(nomenclature.errors.full_messages).to include(expected_error_message)
      end
    end
  end
end
