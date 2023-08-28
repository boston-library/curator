# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::IdentifierIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::IdentifierIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:descriptive) { create(:curator_metastreams_descriptive) }
    let(:descriptable_object) { descriptive.digital_object }
    let(:indexed) { indexer.map_record(descriptable_object) }

    it 'sets the identifier fields' do
      descriptive.identifier.each do |identifier|
        id_type = identifier.type.underscore
        next if id_type == 'local_filename'

        identifier_field = "#{id_type}#{identifier.invalid ? '_invalid' : ''}"
        expect(indexed["identifier_#{identifier_field}_tsim"]).to include(identifier.label), "failed on #{identifier_field}"
      end
      expect(indexed['identifier_uri_ss'].first).to include(descriptable_object.ark_id.split(':').last)
      expect(indexed['identifier_iiif_manifest_ss'].first).to include("#{descriptable_object.ark_id.split(':').last}/manifest")
    end
  end
end
