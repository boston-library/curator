# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::ControlledTerms::IdFromAuthUniquenessValidator, type: :validators do
  subject { described_class }

  it { is_expected.to be <= ActiveModel::Validator }

  it { is_expected.to respond_to(:new) }

  describe 'instance' do
    subject(:validator_instance) { described_class.new }

    it { is_expected.to respond_to(:validate).with(1).argument }

    context 'no id_from_auth' do
      subject! { validator_instance.validate(record) }

      let!(:authority) { find_authority_by_code('gmgpc') }
      let!(:record) { create(:curator_controlled_terms_subject, authority: authority, term_data: { label: 'Foo' }) }

      it { is_expected.to be(nil) }
    end

    context 'no authority' do
      subject! { validator_instance.validate(record) }

      let!(:record) { create(:curator_controlled_terms_subject, authority: nil, term_data: { id_from_auth: 'testetstetst', label: 'Bar' }) }

      it { is_expected.to be(nil) }
    end

    context 'validation failure' do
      subject!(:record) { build(:curator_controlled_terms_subject, authority: authority, term_data: { id_from_auth: 'foobar', label: 'FooBar' }) }

      let!(:authority) { find_authority_by_code('gmgpc') }
      let!(:existing_record) { create(:curator_controlled_terms_subject, authority: authority, term_data: { id_from_auth: 'foobar', label: 'FooBar' }) }
      let!(:expected_error_message) { "Id from auth #{existing_record.id_from_auth} has already been taken for #{existing_record.class.name}!" }

      before(:each) do
        validator_instance.validate(record)
      end

      it 'is expected to contain errors' do
        expect(record.errors).to have_key(:id_from_auth)
        expect(record.errors.full_messages).to include(expected_error_message)
      end
    end
  end
end
