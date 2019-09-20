# frozen_string_literal: true
module CommonwealthCurator
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
