# frozen_string_literal: true

RSpec.shared_examples 'curator_decorator', type: :decorators do
  describe 'Curator::Decorators::BaseDecorator' do
    subject { decorator }

    it { is_expected.to be_a_kind_of(Curator::Decorators::BaseDecorator) }
    it { is_expected.to respond_to(:blank?, :attributes, :serializable_hash) }

    it 'expects #blank? to return true or false' do
      expect(subject.blank?).to be(true).or be(false)
    end

    it 'expects #attributes to be a kind of Hash' do
      expect(subject.attributes).to be_a_kind_of(Hash)
    end
  end
end

RSpec.shared_examples 'curator_multi_decorator', type: :decorators do
  subject { described_class }

  specify { expect(subject).to respond_to(:wrap_multiple).with(1).argument }

  it 'expects .wrap_multiple to return empty Array by default' do
    expect(subject.wrap_multiple).to be_an_instance_of(Array).and be_empty
  end

  describe '.wrap_multiple' do
    subject { wrapped }

    it { is_expected.to be_kind_of(Enumerable).and all(be_an_instance_of(described_class)) }
  end
end
