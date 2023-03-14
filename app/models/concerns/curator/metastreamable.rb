# frozen_string_literal: true

module Curator
  # includes all metastream concerns in one
  module Metastreamable
    module All
      extend ActiveSupport::Concern
      included do
        include Metastreams::Administratable
        include Metastreams::Workflowable
        include Metastreams::Descriptable

        scope :with_metastreams, -> { with_administrative.with_workflow.with_descriptive }
      end
    end

    module Basic
      extend ActiveSupport::Concern
      included do
        include Metastreams::Administratable
        include Metastreams::Workflowable

        scope :with_metastreams, -> { with_administrative.with_workflow }
      end
    end
  end
end
