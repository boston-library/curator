# frozen_string_literal: true

module Curator
  class Configuration
    attr_writer :ark_manager_api_url
    def ark_manager_api_url
      @ark_manager_api_url || ENV['ARK_MANAGER_API_URL']
    end

    attr_writer :authority_api_url
    def authority_api_url
      @authority_api_url || ENV['AUTHORITY_API_URL']
    end

    attr_writer :avi_processor_url
    def avi_processor_url
      @avi_processor_url || ENV['AVI_PROCESSOR_URL']
    end

    attr_writer :default_ark_params
    def default_ark_params
      @default_ark_params ||
      { namespace_ark: ENV['ARK_NAMESPACE'],
        namespace_id: ENV['ARK_NAMESPACE_ID'],
        url_base: ENV['ARK_URL_BASE']
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
          'solr_writer.batch_size' => 1,
          'solr_writer.solr_update_args' => { softCommit: true },
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