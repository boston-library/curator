# frozen_string_literal: true

RSpec.shared_examples 'field_set_base', type: :model do
  it { is_expected.to be_a_kind_of(Curator::DescriptiveFieldSets::Base) }

  it 'expects to have AttrJson::Model in its .ancestors' do
    expect(described_class.ancestors).to include(AttrJson::Model)
  end

  it 'expects to #respond_to? to AttrJson::Model methods' do
    expect(described_class).to respond_to(:attr_json_config, :attr_json, :attr_json_registry)
  end
end
