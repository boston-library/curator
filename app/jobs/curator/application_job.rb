# frozen_string_literal: true

module Curator
  class ApplicationJob < ActiveJob::Base
    discard_on ActiveJob::DeserializationError, ActiveRecord::RecordNotFound
  end
end
