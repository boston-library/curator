# frozen_string_literal: true

module Curator
  class Configuration
    attr_writer :allmaps_annotations_url
    def allmaps_annotations_url
      @allmaps_annotations_url || ENV['ALLMAPS_ANNOTATIONS_URL']
    end

    attr_writer :allmaps_data_export_url
    def allmaps_data_export_url
      @allmaps_data_export_url || ENV['ALLMAPS_DATA_EXPORT_URL']
    end

    attr_writer :ark_manager_api_url
    def ark_manager_api_url
      @ark_manager_api_url || ENV['ARK_MANAGER_API_URL']
    end

    attr_writer :authority_api_url
    def authority_api_url
      @authority_api_url || ENV['AUTHORITY_API_URL']
    end

    attr_writer :avi_processor_api_url
    def avi_processor_api_url
      @avi_processor_api_url || ENV['AVI_PROCESSOR_API_URL']
    end

    attr_writer :iiif_manifest_url # NOTE: this hits the Commonwealth-public-interface url and NOT the cantaloupe server url
    def iiif_manifest_url
      @iiif_manifest_url || ENV['IIIF_MANIFEST_URL']
    end

    attr_writer :iiif_server_url # NOTE: cantaloupe server url
    def iiif_server_url
      @iiif_server_url || ENV['IIIF_SERVER_URL']
    end

    attr_writer :iiif_server_credentials # NOTE: Cantaloupe server credentials
    def iiif_server_credentials
      @iiif_server_credentials || {
        username: ENV['IIIF_SERVER_USER'],
        secret: ENV['IIIF_SERVER_SECRET']
      }.freeze
    end

    attr_writer :ingest_source_directory
    def ingest_source_directory
      @ingest_source_directory || ENV['INGEST_SOURCE_DIRECTORY']
    end

    attr_writer :default_remote_service_timeout_opts
    def default_remote_service_timeout_opts
      @default_remote_service_timeout_opts ||
      {
        connect: 120,
        read: 240,
        write: 120,
        keep_alive: 120
      }.freeze
    end

    attr_writer :default_remote_service_pool_opts
    def default_remote_service_pool_opts
      @default_remote_service_pool_opts ||
      {
        size: ENV.fetch('RAILS_MAX_THREADS') { 5 }.to_i + 2,
        timeout: 15
      }
    end

    attr_writer :default_ark_params
    def default_ark_params
      @default_ark_params ||
      { namespace_ark: ENV['ARK_NAMESPACE'],
        namespace_id: ENV['ARK_MANAGER_DEFAULT_NAMESPACE'],
        oai_namespace_id: ENV['ARK_MANAGER_OAI_NAMESPACE'],
        url_base: ENV['ARK_MANAGER_DEFAULT_BASE_URL']
      }.freeze
    end

    attr_writer :fedora_credentials
    def fedora_credentials
      @fedora_credentials ||
      { fedora_username: ENV['FEDORA_USERNAME'],
        fedora_password: ENV['FEDORA_PASSWORD']
      }.freeze
    end

    attr_writer :indexable_settings
    def indexable_settings
      @indexable_settings ||
      IndexableSettings.new(
        solr_url: solr_url,
        model_name_solr_field: 'curator_model_ssi',
        solr_id_value_attribute: 'ark_id',
        writer_class_name: 'Traject::SolrJsonWriter',
        writer_settings: {
          'solr_writer.thread_pool' => 0,
          'solr_writer.solr_update_args' => { softCommit: true },
          'solr_writer.batch_size' => 1,
          'solr_writer.http_timeout' => 3,
          'logger' => Rails.logger
        },
        disable_callbacks: false
      )
    end

    attr_writer :solr_url
    def solr_url
      @solr_url || ENV['SOLR_URL']
    end
  end
end
