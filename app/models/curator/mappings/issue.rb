# frozen_string_literal: true

module Curator
  class Mappings::Issue < ApplicationRecord
    with_options class_name: Curator.digital_object_class_name do
      belongs_to :digital_object, inverse_of: :issue_mapping
      belongs_to :issue_of, inverse_of: :issue_mapping_for
    end

    validates :digital_object_id, uniqueness: true

    validates :issue_of_id, uniqueness: { scope: :digital_object_id, allow_nil: true} 
  end
end
