# frozen_string_literal: true
module Curator
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
