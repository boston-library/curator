# frozen_string_literal: true

require 'curator/engine'
require 'curator/namespace_accessor'
require 'curator/indexable_settings'

module Curator
  extend ActiveSupport::Autoload
  include NamespaceAccessor

  class CuratorError < StandardError; end

  eager_autoload do
    autoload :Descriptives
    autoload :Services
    autoload :Parsers
    autoload :Serializers
  end

  def self.eager_load!
    super
    Curator::Descriptives.eager_load!
    Curator::Parsers.eager_load!
    Curator::Services.eager_load!
    Curator::Serializers.eager_load!
  end

  def self.setup!
    init_namespace_accessors!
    Curator::Serializers.setup!
  end

  # based on https://github.com/sciencehistory/kithe/blob/ae4f1780451b4f15577b298f57503880cc2c4681/lib/kithe.rb
  # settings need to live here, not in Curator::Indexable, to avoid
  # Rails dev-mode class-reloading weirdness. This module is not reloaded.
  mattr_accessor :indexable_settings do
    # set up default settings
    IndexableSettings.new(
      solr_url: ENV['SOLR_URL'],
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
end
