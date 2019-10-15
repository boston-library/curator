# frozen_string_literal: true
module Curator
  class CuratorSerializer < ActiveModel::Serializer
    attributes :id, :created_at, :updated_at

    def serializable_hash(adapter_options = nil, options = {}, adapter_instance = self.class.serialization_adapter_instance)
      hash = deep_reject_nil_vals(super)
      hash
    end

    private
    def deep_reject_nil_vals(hash={})
      hash.each do |key, value|
        if value.blank?
          hash.delete(key)
        elsif value.is_a?(Hash)
          deep_reject_nil_vals(value)
        elsif value.is_a?(Array) && value.all?{|el| el.is_a?(Hash)}
          value.each {|el| deep_reject_nil_vals(el)}
        end
      end
      hash
    end
  end
end
