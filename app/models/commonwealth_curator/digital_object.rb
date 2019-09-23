# frozen_string_literal: true
module CommonwealthCurator
  class DigitalObject < ApplicationRecord
    include CommonwealthCurator::Mintable
    include CommonwealthCurator::Metastreamable
  end
end
