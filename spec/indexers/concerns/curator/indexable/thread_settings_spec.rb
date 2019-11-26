# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexable::ThreadSettings do
  # These specs are skipped because they cause difficult-to-debug intermittent failures for other indexing specs,
  # specifically '#update_index' specs for Curator::Indexable::RecordIndexUpdater and Curator::Indexable
  # given that this class is not currently used (and was copied verbatim from sciencehistory/kithe),
  # we will leave these skipped for now, possibly revisit or simply remove later

  let(:thread_settings) do
    described_class.push(batching: true, disable_callbacks: false,
                         original_settings: { disable_callbacks: false }, writer: nil, on_finish: nil)
  end

  describe '#writer' do
    # subject { thread_settings.writer }

    it 'returns the writer instance' do
      # expect(subject).to be_an_instance_of Traject::SolrJsonWriter
      skip('These specs cause intermittent failures for other indexing specs!')
    end

    it 'sets the batch size' do
      # expect(subject.settings['solr_writer.batch_size']).to eq 100
      skip('These specs cause intermittent failures for other indexing specs!')
    end
  end

  describe '#disabled_callbacks?' do
    it 'returns the passed argument' do
      # expect(thread_settings.disabled_callbacks?).to be_falsey
      skip('These specs cause intermittent failures for other indexing specs!')
    end
  end

  describe '#pop' do
    it 'returns something' do
      # expect(thread_settings.pop).to be_truthy
      skip('Not exactly sure what this method should be returning?')
    end
  end
end
