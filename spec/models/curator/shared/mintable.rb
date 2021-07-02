# frozen_string_literal: true

RSpec.shared_examples_for 'mintable', type: :model do
  describe 'Mintable' do
    it { is_expected.to respond_to(:ark_id, :ark_params) }

    describe 'Database' do
      it { is_expected.to have_db_column(:ark_id).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_index(:ark_id).unique(true) }
    end

    describe 'Validations' do
      before(:context) { described_class.skip_callback(:validation, :before, :generate_ark_id) }

      after(:context) { described_class.set_callback(:validation, :before, :generate_ark_id) }

      it { is_expected.to validate_presence_of(:ark_id).on(:create) }
      it { is_expected.to validate_uniqueness_of(:ark_id).on(:create) }
    end

    describe '#generate_ark_id on create' do
      subject { build(factory_key_for(described_class), ark_id: nil) }

      it 'generates an #ark_id #before_validation on create if there is none' do
        # valid? invokes the before_validation callback without saving
        VCR.use_cassette("services/mintable_#{described_class.name.demodulize.underscore}", record: :new_episodes) do
          expect { subject.valid? }.to change(subject, :ark_id).
          from(nil).
          to(a_string_starting_with('bpl-dev'))
        end
      end
    end
  end
end
