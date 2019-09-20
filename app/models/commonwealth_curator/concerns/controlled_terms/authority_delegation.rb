# frozen_string_literal: true
module CommonwealthCurator
  module AuthorityDelegation
    extend ActiveSupport::Concern
    included do
      default_scope { includes(:authority) }
      # accepts_nested_attributes_for :authority, reject_if: proc {|attributes| attributes['id'].blank? attributes['base_url'].blank? && attributes['name'].blank? }, allow_destroy: false

      delegate :name, :code, :base_url, :is_getty?, to: :authority, prefix: true, allow_nil: true #authority_#attr

      validates :authority_id, uniqueness: { scope: '(term_data-> "id_from_auth")' }, allow_nil: true }, if: Proc.new {|ct| ct.authority.present?  && ct.id_from_auth.present? } #We want these to be unique if the authority is present

      def value_uri
        Addressable::URI.join("#{authority_base_url}/", id_from_auth).to_s if authority_base_url.present? && id_from_auth.present?
      end

      protected
      #Needed For Cannonicable
      def should_get_cannonical?
        self.label.blank? && label_required? && value_uri.present?
      end

      def label_required?
        self.class.validators.flat_map{|c| c.attributes if c.kind == :presence}.compact.include?(:label)
      end
    end
  end
end
