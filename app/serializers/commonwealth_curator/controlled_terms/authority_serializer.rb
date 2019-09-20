# frozen_string_literal: true
module CommonwealthCurator
  class ControlledTerms::AuthoritySerializer < ApplicationSerializer
    attributes :name, :code, :base_url
  end
end
