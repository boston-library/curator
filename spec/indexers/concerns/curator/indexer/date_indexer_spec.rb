# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::DateIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::DateIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:descriptive) { create(:curator_metastreams_descriptive) }
    let(:descriptable_object) { descriptive.digital_object }
    let(:indexed) { indexer.map_record(descriptable_object) }

    it 'sets the date field' do
      expect(indexed['date_tsim'].first).to match(/\A\d{4}/)
    end

    it 'sets the start date field' do
      expect(indexed['date_start_dtsi'].first).to match(/\A\d{4}-\d{2}-\d{2}T00:00:00.000Z\z/)
    end

    it 'sets the end date field' do
      expect(indexed['date_end_dtsi'].first).to match(/\A\d{4}-\d{2}-\d{2}T23:59:59.999Z\z/)
    end

    it 'sets the date_type field' do
      expect(indexed['date_type_ssm'].first).to match(/dateCreated|dateIssued|copyrightDate/)
    end

    it 'sets the date_facet_yearly field' do
      expect(indexed['date_facet_yearly_itim'].map(&:class).uniq.first).to eq Integer
    end

    it 'sets the date_edtf field' do
      expect(indexed['date_edtf_ssm'].first).to match(/\A\d{4}/)
    end
  end
end
