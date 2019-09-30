# frozen_string_literal: true
module Curator
  class ControlledTerms::AuthoritySerializer < CuratorSerializer
    attributes :name, :code, :base_url
  end
end
