# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Metastreams::SubjectNameModsPresenter, type: :presenters do
  subject { described_class }

  it { is_expected.to respond_to(:new).with(1..2).arguments }

  describe 'instance' do
    subject { described_class.new(name_subject) }

    let!(:name_subject) { create(:curator_controlled_terms_name, name_type: 'conference') }
    let!(:delegated_name_methods) { %i(authority_code authority_base_url value_uri name_type) }

    it { is_expected.to respond_to(:name, :name_parts, *delegated_name_methods).with(0).arguments }
    it { is_expected.not_to be_blank }

    specify { expect(subject.name).to be_an_instance_of(Curator::ControlledTerms::Name) }

    it 'is expected to delegate certain methods to name' do
      delegated_name_methods.each do |delegated_name_method|
        expect(subject).to delegate_method(delegated_name_method).to(:name).allow_nil
      end
    end

    it 'expects #name_parts to be an empty array by default' do
      expect(subject.name_parts).to be_an_instance_of(Array).and be_empty
    end

    context 'personal_name' do
      subject { described_class.new(personal_name_subject, personal_name_parts) }

      let!(:personal_name_subject) { create(:curator_controlled_terms_name, name_type: 'personal', label: Faker::Name.name_with_middle) }
      let!(:personal_name_parts) { map_name_parts(personal_name_subject) }

      it 'expects all the #name_parts to be instances of Curator::Mappings::NamePartModsPresenter' do
        expect(subject.name_parts).to be_an_instance_of(Array)
        expect(subject.name_parts).not_to be_empty
        expect(subject.name_parts).to all(be_an_instance_of(Curator::Mappings::NamePartModsPresenter))
      end

      it 'expects the labels to match the labels in personal_name_parts' do
        expect(subject.name_parts.map(&:label)).to match_array(personal_name_parts.map(&:label))
      end
    end

    context 'corporate_name' do
      subject { described_class.new(corp_name_subject, corp_name_parts) }

      let!(:corp_name_subject) { create(:curator_controlled_terms_name, name_type: 'corporate', label: Faker::University.name ) }
      let!(:corp_name_parts) { map_name_parts(corp_name_subject) }

      it 'expects all the #name_parts to be instances of Curator::Mappings::NamePartModsPresenter' do
        expect(subject.name_parts).to be_an_instance_of(Array)
        expect(subject.name_parts).not_to be_empty
        expect(subject.name_parts).to all(be_an_instance_of(Curator::Mappings::NamePartModsPresenter))
      end

      it 'expects the labels to match the labels in personal_name_parts' do
        expect(subject.name_parts.map(&:label)).to match_array(corp_name_parts.map(&:label))
      end
    end
  end
end
