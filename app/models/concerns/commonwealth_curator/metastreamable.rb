# frozen_string_literal: true
module CommonwealthCurator
  #includes all metastream concerns in one
  module Metastreamable
    extend ActiveSupport::Concern
    included do
      include Metastreams::Administratable
      include Metastreams::Workflowable
      include Metastreams::Descriptable
    end
  end
end
