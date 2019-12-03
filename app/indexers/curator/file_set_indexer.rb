# frozen_string_literal: true

module Curator
  class FileSetIndexer < Curator::Indexer
    include Curator::Indexer::WorkflowIndexer

    # NOTE: fields below were previously set in Bplmodels::File#to_solr, but no longer needed(?):
    #   label_ssi filename_ssi page_num_label_type_ssi

    # NOTE: fields below were previously set in Bplmodels::File#to_solr, but have been updated:
    #   derivative_processsed_ssi->processing_state_ssi

    # TODO: add indexing for:
    #         ocr_tsiv has_ocr_text_bsi edit_access_group_ssim
    #         has_djvu_json_ssi georeferenced_bsi
    configure do
      to_field 'filename_base_ssi', obj_extract('file_name_base')
      to_field 'position_fsi', obj_extract('position', 'to_f')
      to_field('page_type_ssi') { |rec, acc| acc << rec.pagination['page_type'] }
      to_field('page_num_label_ssi') { |rec, acc| acc << rec.pagination['page_label'] }
    end
  end
end
