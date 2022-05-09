# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::ControlledTerms::ResourceTypeModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:wrap_multiple).with(0..1).arguments.and_keywords(:resource_type_manuscript) }
  it { is_expected.to respond_to(:new).with(1).argument.and_keywords(:resource_type_manuscript) }

  it 'expects .wrap_multiple to return empty array by default' do
    expect(subject.wrap_multiple).to be_an_instance_of(Array).and be_empty
  end

  describe 'instance' do
    subject { described_class.new(resource_type) }

    let!(:resource_types) { Curator::ControlledTerms::ResourceType.order(Arel.sql('RANDOM()')).limit(3) }
    let!(:resource_type) { resource_types.last }

    it { is_expected.to respond_to(:resource_type, :resource_type_manuscript, :resource_type_manuscript?, :manuscript_label, :label).with(0).arguments }
    it { is_expected.to delegate_method(:label).to(:resource_type).allow_nil }
    it { is_expected.not_to be_resource_type_manuscript }

    it 'is expected to have the correct values' do
      expect(subject.resource_type).to be_an_instance_of(Curator::ControlledTerms::ResourceType)
      expect(subject.label).to eql(resource_type.label)
      expect(subject.resource_type_manuscript).to be(false)
      expect(subject.manuscript_label).to be(nil)
    end

    context 'resource_type_manuscript = true' do
      subject { described_class.new(resource_type, resource_type_manuscript: true) }

      specify { expect(subject.resource_type_manuscript).to be(true) }

      it { is_expected.to be_resource_type_manuscript }

      it 'expects #manuscript_label to return yes' do
        expect(subject.manuscript_label).to eql('yes')
      end
    end

    context 'with .wrap_multiple and resource_type_manuscript = yes' do
      subject { described_class.wrap_multiple(resource_types, resource_type_manuscript: true) }

      it { is_expected.to all(be_an_instance_of(described_class)) }
      it { is_expected.to all(be_resource_type_manuscript) }

      it 'expects all items #manuscript_label method to return yes' do
        expect(subject.map(&:manuscript_label)).to all(eql('yes'))
      end
    end
  end
end
