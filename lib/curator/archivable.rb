# frozen_string_literal: true
module Curator
  module Archivable
    extend ActiveSupport::Concern
    included do
      scope :live, -> { where(archived: false) }
      scope :archived, -> { unscope(where: :archived).where(archived: true) }
      default_scope { live }
    end

    def delete(mode=:soft)
      if mode == :hard
        super()
      else
        update(archived: true)
      end
    end

    def recover
      update(archived: false)
    end

    def deleted?
      archived?
    end
  end
end
