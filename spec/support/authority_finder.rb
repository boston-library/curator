# frozen_string_literal: true

module AuthorityFinder
  def find_authority_by_code(code = '')
    Curator::ControlledTerms::Authority.find_by(code: code)
  end
end

RSpec.configure do |config|
  config.include AuthorityFinder, type: :model
end
