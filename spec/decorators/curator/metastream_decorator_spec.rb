# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/curator_decorator'

RSpec.describe Curator::MetastreamDecorator, type: :decorators do
  let!(:metastreamable_record) { create(:curator_institution) }

  describe 'Base Behavior' do
    it_behaves_like 'curator_decorator' do
      let(:decorator) { described_class.new(metastreamable_record) }
    end
  end

  describe 'Decorator specific behavior' do
    subject { described_class.new(metastreamable_record) }

    let(:expected_blank_condition) { subject.administrative.blank? && subject.descriptive.blank? && subject.workflow.blank? }

    it { is_expected.to respond_to(:administrative, :descriptive, :workflow) }

    it 'is expected to return #blank? based on the :expected_blank_condition' do
      expect(subject.blank?).to eq(expected_blank_condition)
    end
  end
end
