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


  before(:each) do
    ActiveJob::Base.queue_adapter = :test
  end

  it 'Updates the solr index for all the objects in the DB' do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    time = Time.current

    # Rake::Task['']
  end
end
