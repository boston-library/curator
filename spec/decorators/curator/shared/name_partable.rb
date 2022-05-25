# frozen_string_literal: true

RSpec.shared_examples_for 'name_partable', type: :decorators do
  specify { expect(name_partable_decorator_inst).to be_truthy.and be_an_instance_of(described_class) }

  describe '#name_parts' do
    subject { name_partable_decorator_inst }

    specify { expect(subject).to respond_to(:name, :name_type).with(0).arguments }

    it { is_expected.to respond_to(:name_parts).with(0).arguments }

    it 'expects #name_parts to return an array of Curator::Curator::Mappings::NamePartModsPresenters' do
      expect(subject.name_parts).to be_an_instance_of(Array)
      expect(subject.name_parts).not_to be_empty
      expect(subject.name_parts).to all(be_an_instance_of(Curator::Mappings::NamePartModsPresenter))
    end
  end
end
