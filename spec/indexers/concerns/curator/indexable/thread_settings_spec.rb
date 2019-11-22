# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexable::ThreadSettings do
  let(:thread_settings) do
    described_class.push(batching: true, disable_callbacks: false,
                         original_settings: { disable_callbacks: false }, writer: nil, on_finish: nil)
  end

  describe '#writer' do
    subject { thread_settings.writer }
    it { is_expected.to be_an_instance_of Traject::SolrJsonWriter }
    it 'sets the batch size' do
      expect(subject.settings['solr_writer.batch_size']).to eq 100
    end
  end

  describe '#disabled_callbacks?' do
    it 'returns the passed argument' do
      expect(thread_settings.disabled_callbacks?).to be_falsey
    end
  end

  describe '#pop' do
    it 'returns something' do
      # expect(thread_settings.pop).to be_truthy
      skip('Not exactly sure what this method should be returning?')
    end
  end
end
