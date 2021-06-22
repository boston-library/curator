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
        include Metastreamable::InstanceMethods

        scope :with_metastreams, -> { includes(:administrative, :descriptive, :workflow) }
      end
    end

    module Basic
      extend ActiveSupport::Concern
      included do
        include Metastreams::Administratable
        include Metastreams::Workflowable
        include Metastreamable::InstanceMethods
        scope :with_metastreams, -> { includes(:administrative, :workflow) }
      end
    end

    module InstanceMethods
      def metastreams
        return @metastreams if defined?(@metastreams)

        @metastreams = Curator::MetastreamDecorator.new(self)
      end
    end
  end
end
