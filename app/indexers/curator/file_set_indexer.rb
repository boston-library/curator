# frozen_string_literal: true

module Curator
  class FileSetIndexer < Curator::Indexer
    # NOTE: fields below were previously set in Bplmodels::File#to_solr, but no longer needed(?):
    #   label_ssim filename_ssi

    # NOTE: fields below were previously set in Bplmodels::File#to_solr, but have been updated:
    #

    # TODO: add indexing for:
    #         derivative_processsed_ssi ocr_tsiv has_ocr_text_bsi
    #         page_num_label_type_ssi
    #         has_djvu_json_ssi georeferenced_bsi
    configure do
      to_field 'filename_base_ssi', obj_extract('file_name_base')
      to_field 'position_fsi', obj_extract('position', 'to_f')
      to_field('page_type_ssi') { |rec, acc| acc << rec.pagination['page_type'] }
      to_field('page_num_label_ssi') { |rec, acc| acc << rec.pagination['page_label'] }
    end
  end
end
