# frozen_string_literal: true

# Helpers to Build request params depending on :file_set_type
module FileSetRequestHelpers
  def can_be_exemplary?(file_set_type = '')
    return false if file_set_type.blank? || file_set_type.underscore == 'file_set'

    Curator::Mappings::ExemplaryImage::VALID_EXEMPLARY_FILE_SET_TYPES.include?(file_set_type.camelize)
  end
end

RSpec.configure do |config|
  config.include FileSetRequestHelpers, type: :request
  config.include FileSetRequestHelpers, type: :controller
end
