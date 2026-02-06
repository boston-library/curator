# frozen_string_literal: true

require 'rails_helper'
Rails.application.load_tasks

# because this task loads a static export file, we can't run specs against production data,
# so we mock up a test export file using ids for dynamically created DigitalObject fixtures
RSpec.describe 'curator:allmaps_status task', type: :task do
  let!(:institution) { create(:curator_institution, :with_location) }
  let!(:collection) { create(:curator_collection, institution: institution) }
  let!(:digital_object) { create(:curator_digital_object, admin_set: collection) }
  let!(:ark_id) { digital_object.ark_id }
  let!(:solr_client) { RSolr.connect url: Curator.config.solr_url }
  let(:digital_object_timestamp) { } # TK, figure out how to fetch a single record with RSolr
  before(:each) do
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
    # TK write the data to spec/internal/public/allmaps_annotations_export_test.json
  end

  it 'triggers a reindex for items in the data export file' do
    current_timestamp = Time.current
    VCR.use_cassette('tasks/allmaps_status') do
      Rails.logger.silence do
        Rake::Task['curator:allmaps_status'].invoke
      end
    end
    expect(record_timestamps.count).to eq(ark_ids.count)
    expect(record_timestamps).to all(be > current_timestamp)
  end
end
