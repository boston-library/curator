# frozen_string_literal: true

module Curator
  class Metastreams::DescriptiveUpdaterService < Services::Base
    include Services::UpdaterService

    SIMPLE_ATTRIBUTES_LIST = %i(abstract access_restrictions digital_origin frequency
                                 issuance origin_event extent physical_location_department
                                 physical_location_shelf_locator place_of_publication
                                 publisher rights series subseries subsubseries toc toc_url
                                 resource_type_manuscript text_direction).freeze

    def call
      with_transaction do
        simple_attributes_update(SIMPLE_ATTRIBUTES_LIST) do |simple_attr|
          @record.public_send("#{simple_attr}=", @json_attrs.fetch(simple_attr))
        end
      end

      return @success, @result
    end
  end
end
