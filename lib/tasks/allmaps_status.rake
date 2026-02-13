# frozen_string_literal: true

namespace :curator do
  desc 'check Allmaps georeferencing status for cartographic materials and reindex'
  task allmaps_status: :environment do
    Rails.logger.info 'Running allmaps_status task, checking for newly georeferenced items...'
    data_resp = Faraday.get(Curator.config.allmaps_data_export_url)
    raise Curator::Exceptions::AllmapsAnnotationsUnavailable, 'COULD NOT PARSE ALLMAPS DATA EXPORT' unless data_resp.status == 200

    allmaps_data = JSON.parse(data_resp.body)
    regexp_pattern = /#{Curator.config.ark_manager_api_url}\/ark:\/50959\/[0-9a-z]{9}\/manifest/
    ark_ids = []
    # iterate over the data, find items with IIIF manifest links
    allmaps_data['items'].each do |am_item|
      manifest_url = am_item.to_s.match(regexp_pattern).to_s
      ark_ids << "#{Curator.config.default_ark_params[:namespace_id]}:#{manifest_url.split('/')[-2]}" if manifest_url.present?
    end

    # reindex any items that are currently un-georeferenced,
    # query Solr, since we don't store Allmaps status in Curator data model
    solr = RSolr.connect(url: Curator.config.solr_url)
    q_params = %w(destination_site_ssim:nblmc hosting_status_ssi:hosted type_of_resource_ssim:Cartographic
                  curator_model_suffix_ssi:DigitalObject processing_state_ssi:complete -georeferenced_allmaps_bsi:true)
    resp = solr.get('select', params: { q: q_params.join(' AND '), rows: 50_000, fl: 'id' })
    nongeorefd = resp.dig('response', 'docs').map { |doc| doc['id'] }

    ark_ids.uniq.each do |ark_id|
      next unless nongeorefd.include?(ark_id)

      Rails.logger.info "Reindexing #{ark_id} to update georeferencing status"
      Curator.digital_object_class.find_ark(ark_id).queue_indexing_job
      sleep(1)
    end
    Rails.logger.info 'allmaps_status task completed.'
  end
end
