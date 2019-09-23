# frozen_string_literal: true
module CommonwealthCurator
  class Institution < ApplicationRecord
    include CommonwealthCurator::Mintable
    include CommonwealthCurator::Metastreamable
    has_many :host_collections, inverse_of: :institution, class_name: 'CommonwealthCurator::Mappings::HostCollection'
    #host_collections is a mapping object
    has_many :collections, inverse_of: :institution, class_name: 'CommonwealthCurator::Collection'
  end
end
