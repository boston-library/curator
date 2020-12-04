# frozen_string_literal: true

RSpec.shared_examples 'access_condition', type: :model do
  it { is_expected.to be_a_kind_of(Curator::ControlledTerms::AccessCondition) }

  describe 'attr_json attributes' do
    it { is_expected.to respond_to(:uri) }

    it 'expects the attributes to have specific types' do
      expect(described_class.attr_json_registry.fetch(:uri, nil)&.type).to be_a_kind_of(ActiveModel::Type::String)
    end

    describe 'Validations' do
      it { is_expected.to validate_presence_of(:label) }
      it { is_expected.to allow_values('http://something.org', 'https://somethingelse.org').for(:uri) }
      it { is_expected.not_to allow_values('not', 'a', 'random', 'string', 'or', 'non-url').for(:uri) }
    end

    describe 'Associations' do
      describe 'Not mappable' do
        it { is_expected.not_to respond_to(:desc_terms) }
      end

      it { is_expected.to belong_to(:authority).
          class_name('Curator::ControlledTerms::Authority').
          optional }
    end
  end
end
