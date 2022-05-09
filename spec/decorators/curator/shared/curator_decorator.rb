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
  specify { expect(described_class).to respond_to(:wrap_multiple) }

  describe '.wrap_multiple' do
    subject { wrapped }

    it { is_expected.to be_kind_of(Enumerable).and all(be_an_instance_of(described_class)) }
  end
end
