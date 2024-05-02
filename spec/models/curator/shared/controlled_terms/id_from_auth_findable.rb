# frozen_string_literal: true

RSpec.shared_examples 'id_from_auth_findable', type: :model do |test_multiple: false|
  describe 'Class Methods' do
    subject { described_class }

    it { is_expected.to be_const_defined(:MultipleIdFromAuthError) }

    it { is_expected.to respond_to(:find_id_from_auth, :find_id_from_auth!).with(1).argument }

    describe 'find_id_from_auth' do
      subject { described_class.find_id_from_auth(id_from_auth) }

      let!(:nomenclature) { create(factory_key_for(described_class), term_data: term_data, authority: authority) }

      it { is_expected.to be_truthy.and eql(nomenclature) }

      context 'when multiple', if: test_multiple do
        let!(:error_class) { described_class.const_get(:MultipleIdFromAuthError) }

        before(:each) do
          create(factory_key_for(described_class), term_data: term_data, authority: other_authority)
        end

        it 'is expected to raise an ::MultipleIdFromAuthError error' do
          expect { described_class.find_id_from_auth!(id_from_auth) }.to raise_error(error_class, "Multiple results found for #{id_from_auth}!")
        end
      end

      context 'when not found' do
        subject { described_class.find_id_from_auth('notarealidfromauth') }

        it { is_expected.to be_nil }
      end
    end

    describe 'find_id_from_auth!' do
      subject { described_class.find_id_from_auth!(id_from_auth) }

      let!(:nomenclature) { create(factory_key_for(described_class), term_data: term_data, authority: authority) }

      it { is_expected.to be_truthy.and eql(nomenclature) }

      context 'when multiple', if: test_multiple do
        let!(:error_class) { described_class.const_get(:MultipleIdFromAuthError) }

        before(:each) do
          create(factory_key_for(described_class), term_data: term_data, authority: other_authority)
        end

        it 'is expected to raise an ::MultipleIdFromAuthError error' do
          expect { described_class.find_id_from_auth!(id_from_auth) }.to raise_error(error_class, "Multiple results found for #{id_from_auth}!")
        end
      end

      context 'when not found' do
        it 'is expected to raise an ActiveRecord::RecordNotFound error' do
          expect { described_class.find_id_from_auth!('notarealidfromauth') }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find #{described_class.name}/)
        end
      end
    end
  end
end