# frozen_string_literal: true
module Curator
  module Services
    module FactoryService
      extend ActiveSupport::Concern

      protected
      def build_descriptive(descriptable, &block)
        descriptive = Metastreams::Descriptive.new(descriptable: descriptable)
        yield descriptive
        descriptive.save!
      end


      def build_workflow(workflowable, &block)
        workflow = Curator.metastreams.workflow_class.new(workflowable: workflowable )
        yield(workflow)
        workflow.save!
      end

      def build_administrative(administratable, &block)
        administrative = Curator.metastreams.administrative_class.new(administratable: administratable )
        yield(administrative)
        administrative.save!
      end

      def build_exemplary(exemplary_object, &block)
        exemplary = Curator.mappings.exemplary_image_class.new(exemplary_object: exemplary_object)
        yield(exemplary)
        exemplary.save!
      end


      private
      def find_or_create_nomenclature(nomenclature_class:, term_data: {}, authority_code: nil )
        begin
          if authority_code.present?
            authority = Curator.controlled_terms.authority_class.find_by(code: authority_code)
            raise "No authority found with the code #{authority_code}!" if authority.blank?
            return nomenclature_class.where(authority: authority, term_data: term_data).first_or_create!
          else
            return nomenclature_class.where(term_data: term_data).first_or_create!
          end
        rescue => e
          puts e.message
        end
        nil
      end
    end
  end
end
