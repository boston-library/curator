# frozen_string_literal: true

RSpec.shared_examples 'authority_delegation', type: :model do
  subject { create(factory_key_for(described_class)) }

  it 'expects the the class to have the #with_authority scope' do
    expect(described_class).to respond_to(:with_authority)
  end

  it { is_expected.to delegate_method(:name).to(:authority).with_prefix(true).allow_nil }
  it { is_expected.to delegate_method(:code).to(:authority).with_prefix(true).allow_nil }
  it { is_expected.to delegate_method(:base_url).to(:authority).with_prefix(true).allow_nil }
  it { is_expected.to delegate_method(:canonical_json_format).to(:authority).allow_nil }

  it { is_expected.to respond_to(:value_uri) }

  # TODO: Can't test below validation spec due to how the validation works in shoulda-matchers. Need to find a way to override
  # it { is_expected.to validate_uniqueness_of(:authority_id).allow_nil }
end
