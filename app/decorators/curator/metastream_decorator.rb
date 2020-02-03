# frozen_string_literal: true

module Curator
  class MetastreamDecorator < Decorators::BaseDecorator
    attr_reader :administrative, :descriptive, :workflow
    def initialize(metastreamable_object)
      super(metastreamable_object)
      @administrative = metastreamable_object.administrative if metastreamable_object.respond_to?(:administrative)
      @descriptive = metastreamable_object.descriptive if metastreamable_object.respond_to?(:descriptive)
      @workflow = metastreamable_object.workflow if metastreamable_object.respond_to?(:workflow)
    end
  end
end
