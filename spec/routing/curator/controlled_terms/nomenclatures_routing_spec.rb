# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/shared_routing'

RSpec.describe Curator::ControlledTerms::NomenclaturesController, type: :routing do
  routes { Curator::Engine.routes }
  let!(:default_format) { :json }
  let!(:default_id) { '1' }
  let!(:default_controller) { 'curator/controlled_terms/nomenclatures' }

  describe 'default routing' do
    Curator.controlled_terms.nomenclature_types.map(&:downcase).each do |nomenclature_type|
      describe "#{nomenclature_type} collection routes" do
        include_examples 'sti_collection' do
          subject { controlled_terms_nomenclatures_path(type: nomenclature_type) }
          let(:expected_type) { nomenclature_type }
          let(:expected_controller) { default_controller }
          let(:expected_format) { default_format }
        end
      end

      describe "#{nomenclature_type} member routes" do
        include_examples 'sti_member' do
          subject { controlled_terms_nomenclature_path(default_id, type: nomenclature_type) }
          let(:expected_type) { nomenclature_type }
          let(:expected_controller) { default_controller }
          let(:expected_id) { default_id }
          let(:expected_format) { default_format }
        end
      end
    end
  end
end
