# frozen_string_literal: true

require 'rails_helper'
Rails.application.load_tasks

RSpec.describe 'curator:reindex_all task', type: :task do
  let!(:institution) { create(:curator_institution, :with_location) }
  let!(:collections) { create_list(:curator_collection, 3, institution: institution) }
  let!(:digital_objects) { create_list(:curator_digital_object, 3, desc_term_count: 3, admin_set: collections.sample) }
  let!(:image_file_sets) { create_list(:curator_filestreams_image, 3, :with_primary_image, file_set_of: digital_objects.sample) }
  let!(:solr_client) { RSolr.connect url: Curator.config.solr_url }
  let!(:ark_ids) { Array.wrap(institution.ark_id) + collections.pluck(:ark_id) + digital_objects.pluck(:ark_id) + image_file_sets.pluck(:ark_id) }
  let!(:solr_query) { { ids: ark_ids.join(',') } }

  let(:solr_response_docs) { solr_client.get('get', params: solr_query).dig('response', 'docs') || [] }
  let(:record_timestamps) { solr_response_docs.pluck('timestamp') }

  # Prevents recording new episodes with junk allmaps requests
  # rubocop:disable RSpec/AnyInstance
  before(:each) do
    allow_any_instance_of(Curator::DigitalObject).to receive(:georeferenceable?).and_return(false)
  end
  # rubocop:enable RSpec/AnyInstance

  it 'Updates the solr index for all the objects in the DB' do
    current_timestamp = Time.current
    VCR.use_cassette('tasks/reindex_all') do
      Rails.logger.silence do
        Rake::Task['curator:reindex_all'].invoke
      end
    end
    expect(record_timestamps.count).to eq(ark_ids.count)
    expect(record_timestamps).to all(be > current_timestamp)
  end
end
