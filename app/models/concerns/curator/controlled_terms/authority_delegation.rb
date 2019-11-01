# frozen_string_literal: true

module Curator
  module ControlledTerms
    module AuthorityDelegation
      extend ActiveSupport::Concern
      included do
        scope :with_authority, -> { includes(:authority) }
        # accepts_nested_attributes_for :authority, reject_if: proc {|attributes| attributes['id'].blank? attributes['base_url'].blank? && attributes['name'].blank? }, allow_destroy: false

        delegate :name, :code, :base_url, to: :authority, prefix: true, allow_nil: true # authority_#attr

        delegate :cannonical_json_format, to: :authority, prefix: false, allow_nil: true

        validates :authority_id, uniqueness: { conditions: -> { where(term_data: { id_from_auth: select(Arel.sql("term_data ->> 'id_from_auth'")).pluck(Arel.sql("term_data ->> 'id_from_auth'")) }) }, allow_nil: true }, if: proc { |n| n.authority.present? && n.id_from_auth.present? } # We want these to be unique if the authority is present

        def value_uri
          Addressable::URI.join("#{authority_base_url}/", id_from_auth).to_s if authority_base_url.present? && id_from_auth.present?
        end
      end
    end
  end
end
