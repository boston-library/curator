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

        scope :with_metastreams, -> { joins(:administrative, :workflow).includes(:administrative, :workflow).merge(with_descriptive) }
      end
    end

    module Basic
      extend ActiveSupport::Concern
      included do
        include Metastreams::Administratable
        include Metastreams::Workflowable
        include Metastreamable::InstanceMethods
        scope :with_metastreams, -> { joins(:descriptive, :workflow).includes(:administrative, :workflow) }
      end
    end

    module InstanceMethods
      def metastreams
        Curator::MetastreamDecorator.new(self)
      end
    end
  end
end
