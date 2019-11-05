# frozen_string_literal: true

RSpec.shared_examples_for 'mintable', type: :model do
  describe '#ark_id' do
    it { is_expected.to have_db_column(:ark_id).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_index(:ark_id).unique(true) }
    it { is_expected.to validate_presence_of(:ark_id) }
    it { is_expected.to validate_uniqueness_of(:ark_id) }
  end

  describe "#generate_ark_id on create" do
    subject { build(factory_key_for(described_class), ark_id: nil) }

    it 'generates an #ark_id #before_validation on create if there is none' do
      # valid? invokes the before_validation callback without saving
      expect { subject.valid? }.to change { subject.ark_id }.
      from(nil).
      to(a_string_starting_with('commonwealth'))
    end
  end
end
