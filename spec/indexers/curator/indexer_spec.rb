# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer do
  describe '#default_settings' do
    subject { described_class.default_settings }
    it 'sets default settings' do
      expect(subject).not_to be_falsey
      expect(subject['processing_thread_pool']).to eq 0
    end
  end

  describe 'indexing' do
    let(:indexer) { described_class.new }
    let(:institution) { create(:curator_institution) }
    let(:indexed) { indexer.map_record(institution) }

    it 'should set the fields correctly' do
      expect(indexed['id']).to eq [institution.ark_id]
      expect(indexed['system_create_dtsi']).to eq [institution.created_at]
      expect(indexed['system_modified_dtsi']).to eq [institution.updated_at]
      expect(indexed[Curator.indexable_settings.model_name_solr_field]).to eq [institution.class.name]
      expect(indexed['curator_model_suffix_ssi']).to eq [institution.class.name.demodulize]
    end
  end
end
