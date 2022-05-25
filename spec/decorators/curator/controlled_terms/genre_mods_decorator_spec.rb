# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/curator_decorator'

RSpec.describe Curator::ControlledTerms::GenreModsDecorator, type: :decorators do
  let!(:genres) { Curator::ControlledTerms::Genre.order(Arel.sql('RANDOM()')).limit(3) }

  describe 'Base Behavior' do
    it_behaves_like 'curator_decorator' do
      let(:decorator) { described_class.new(genres.sample) }
    end

    it_behaves_like 'curator_multi_decorator' do
      let(:wrapped) { described_class.wrap_multiple(genres) }
    end
  end

  describe 'Decorator specific behavior' do
    subject { described_class.new(genre) }

    let!(:genre) { genres.sample }
    let!(:expected_display_label) { genre.basic? ? 'general' : 'specific' }
    let!(:expected_blank_condition) { subject.label.blank? && subject.authority.blank? && subject.authority_uri.blank? && subject.value_uri.blank? && subject.display_label.blank? }

    it { is_expected.to respond_to(:label, :authority, :authority_uri, :value_uri, :display_label).with(0).arguments }

    it 'is expected to return #blank? based on the :expected_blank_condition' do
      expect(subject.blank?).to eq(expected_blank_condition)
    end

    it 'expects the decorator methods to return the correct values' do
      expect(subject.label).to eql(genre.label)
      expect(subject.authority).to eql(genre.authority_code)
      expect(subject.authority_uri).to eql(genre.authority_base_url)
      expect(subject.value_uri).to eql(genre.value_uri)
      expect(subject.display_label).to eql(expected_display_label)
    end
  end
end
