# frozen_string_literal: true

require 'rails_helper'
Rails.application.load_tasks

# because this task loads a static export file, and we can't run specs against production data,
# we need to mock up a test export file using the ids from dynamically created DigitalObject fixtures
RSpec.describe 'curator:allmaps_status task', type: :task do
  let!(:descriptive) { build(:curator_metastreams_descriptive, :with_all_desc_terms, desc_term_count: 1) }
  let!(:administrative) { build(:curator_metastreams_administrative, :nblmc_destination_site) }
  let!(:digital_object) { create(:curator_digital_object, ark_id: "#{Curator.config.default_ark_params[:namespace_id]}:a0b1c2d3e",
                                 administrative: administrative, descriptive: descriptive) }
  let!(:ark_id) { digital_object.ark_id }
  let!(:solr_client) { RSolr.connect url: Curator.config.solr_url }
  let(:solr_response_doc) { solr_client.get('select', params: { q: "id:\"#{ark_id}\"" }).dig('response', 'docs')&.first || {} }
  let(:digital_object_timestamp) { solr_response_doc['timestamp'] }

  before(:each) do
    digital_object.workflow.processing_state = 'complete'
    digital_object.update_index
    annotation_data = { type: 'AnnotationPage',
                        '@context' => 'http://www.w3.org/ns/anno.jsonld',
                        items: [
                          {
                            id: 'https://annotations.allmaps.org/maps/123456789abcdef',
                            type: 'Annotation',
                            target: {
                              source: {
                                id: "#{Curator.config.iiif_server_url}#{ark_id}",
                                partOf: [
                                  {
                                    id: "#{Curator.config.ark_manager_api_url}/ark:/50959/#{ark_id.split(':').last}/canvas/abcd123456",
                                    type: 'Canvas',
                                    partOf: [
                                      {
                                        id: "#{Curator.config.ark_manager_api_url}/ark:/50959/#{ark_id.split(':').last}/manifest",
                                        type: 'Manifest'
                                      }
                                    ]
                                  }
                                ]
                              }
                            }
                          }
                        ]
    }
    stub_request(:any, Curator.config.allmaps_data_export_url).to_return(body: JSON.pretty_generate(annotation_data), status: 200)
  end

  around(:each) do |spec|
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    spec.run
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = false
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
  end

  it 'triggers a reindex for the ARK ids in the data export file' do
    current_timestamp = DateTime.now
    sleep(2)
    VCR.use_cassette('tasks/allmaps_status') do
      Rake::Task['curator:allmaps_status'].invoke
    end
    expect(Time.parse(digital_object_timestamp) > current_timestamp).to be_truthy
  end
end
