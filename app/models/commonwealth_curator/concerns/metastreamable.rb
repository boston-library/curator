# frozen_string_literal: true
module CommonwealthCurator
  #includes all metastream concerns in one
  module Metastreamable
    include Metastreams::Administratable
    include Metastreams::Workflowable
    include Metastreams::Descriptable
  end
end
