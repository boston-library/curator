# frozen_string_literal: true

module Curator
  # includes all metastream concerns in one
  module Metastreamable
    extend ActiveSupport::Concern
    included do
      include Metastreams::Administratable
      include Metastreams::Workflowable
      include Metastreams::Descriptable

      scope :with_metastreams, -> { merge(with_workflow).merge(with_administrative).merge(with_descriptive) }
    end
  end
end
