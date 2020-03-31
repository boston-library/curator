# frozen_string_literal: true

# based on https://github.com/sciencehistory/kithe/blob/ae4f1780451b4f15577b298f57503880cc2c4681/app/indexing/kithe/solr_util.rb
module Curator
  # Utilities for dealing with your Solr index
  #
  # Unlike other parts of Kithe's indexing support, this stuff IS very solr-specific, and generally
  # implemented with [rsolr](https://github.com/rsolr/rsolr).
  module SolrUtil
    # based on sunspot, does not depend on Blacklight.
    # https://github.com/sunspot/sunspot/blob/3328212da79178319e98699d408f14513855d3c0/sunspot_rails/lib/sunspot/rails/searchable.rb#L332
    #
    #     solr_index_orphans do |orphaned_id|
    #        delete(id)
    #     end
    #
    # It is searching for any Solr object with a `Curator.indexable_settings.model_name_solr_field`
    # field. Then, it takes the ID and makes sure it exists in the database using Curator::Model.
    # TODO: fix below, we have to use Curator.indexable_settings.model_name_solr_field
    # At the moment we are assuming everything is in Curator::Model,
    # rather than trying to use model_name_solr_field value to fetch from different tables.
    #
    # This is intended mostly for use by .delete_solr_orphans
    def self.solr_orphan_ids(batch_size: 100, solr_url: Curator.indexable_settings.solr_url)
      return enum_for(:solr_index_orphan_ids) unless block_given?

      model_name_solr_field = Curator.indexable_settings.model_name_solr_field
      model_solr_id_attr = Curator.indexable_settings.solr_id_value_attribute

      solr_page = -1

      rsolr = RSolr.connect url: solr_url

      while (solr_page = solr_page.next)
        response = rsolr.get 'select', params: {
          rows: batch_size,
          start: (batch_size * solr_page),
          fl: 'id',
          q: "#{model_name_solr_field}:[* TO *]"
        }

        solr_ids = response['response']['docs'].collect { |h| h['id'] }

        break if solr_ids.empty?

        (solr_ids - Curator::Model.where(model_solr_id_attr => solr_ids).pluck(model_solr_id_attr)).each do |orphaned_id|
          yield orphaned_id
        end
      end
    end

    # Finds any Solr objects that have a `model_name_ssi` field
    # (or `Curator.indexable_settings.model_name_solr_field` if non-default), but don't
    # exist in the rdbms, and deletes them from Solr, then issues a commit.
    #
    # Under normal use, you shouldn't have to do this, but can if your Solr index
    # has gotten out of sync and you don't want to delete it and reindex from
    # scratch.
    #
    # Implemented in terms of .solr_orphan_ids.
    #
    # returns an array of any IDs deleted.
    def self.delete_solr_orphans(batch_size: 100, solr_url: Curator.indexable_settings.solr_url)
      rsolr = RSolr.connect url: solr_url
      deleted_ids = []

      solr_orphan_ids(batch_size: batch_size, solr_url: solr_url) do |orphan_id|
        deleted_ids << orphan_id
        rsolr.delete_by_id(orphan_id)
      end

      rsolr.commit

      return deleted_ids
    end

    # Just a utility method to delete everything from Solr, and then issue a commit,
    # using Rsolr. Pretty trivial.
    #
    # Intended for dev/test instances, not really production.
    # @param commit :soft, :hard, or false. Default :hard
    def self.delete_all(solr_url: Curator.indexable_settings.solr_url, commit: :hard)
      rsolr = RSolr.connect url: solr_url

      # RSolr is a bit under-doc'd, but this SEEMS to work to send a commit
      # or softCommit instruction with the delete request.
      params = {}
      if commit == :hard
        params[:commit] = true
      elsif commit == :soft
        params[:softCommit] = true
      end

      rsolr.delete_by_query('*:*', params: params)
    end

    ##
    # check if Solr is online
    # use ENV as default rather than Curator.indexable_settings,
    # since the latter may not be loaded in all cases where this gets called
    def self.solr_ready?(solr_url: ENV['SOLR_URL'])
      rsolr = RSolr.connect url: solr_url
      begin
        ping_request = rsolr.head('admin/ping')
        ping_request.response[:status] == 200 ? true : false
      rescue StandardError => e
        Rails.logger.error "ERROR: Solr is not ready: #{e}"
        false
      end
    end
  end
end
