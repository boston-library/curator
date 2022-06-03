# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/curator_decorator'

RSpec.describe Curator::ControlledTerms::AccessConditionModsDecorator, type: :decorators do
  let!(:licenses) { Curator::ControlledTerms::License.order(Arel.sql('RANDOM()')).limit(3) }
  let!(:rights_statements) { Curator::ControlledTerms::RightsStatement.order(Arel.sql('RANDOM()')).limit(3) }
  let!(:access_conditions) { licenses + rights_statements }

  describe 'Base Behavior' do
    it_behaves_like 'curator_decorator' do
      let(:decorator) { described_class.new(access_conditions.sample) }
    end

    it_behaves_like 'curator_multi_decorator' do
      let(:wrapped) { described_class.wrap_multiple(access_conditions) }
    end
  end

  describe 'Decorator specific behavior' do
    subject { described_class.new(access_condition) }

    let!(:access_condition) { access_conditions.sample }
    let!(:expected_blank_condition) { subject.label.blank? && subject.type.blank? && subject.display_label.blank? && subject.uri.blank? }
    let!(:expected_type) { Curator::ControlledTerms::ACCESS_CONDITION_TYPE }

    it { is_expected.to respond_to(:label, :uri, :type, :display_label).with(0).arguments }

    it 'is expected to return #blank? based on the :expected_blank_condition' do
      expect(subject.blank?).to eq(expected_blank_condition)
    end

    it 'expects the decorator methods to return the correct values' do
      expect(subject.label).to eql(access_condition.label)
      expect(subject.uri).to eql(access_condition.uri)
      expect(subject.display_label).to eql('license').or eql('rights').or eql('rightsstatements.org')
      expect(subject.type).to eql(expected_type)
    end
  end
end
