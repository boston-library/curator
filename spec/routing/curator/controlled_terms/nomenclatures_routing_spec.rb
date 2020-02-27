# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/shared_routing'

RSpec.describe Curator::ControlledTerms::NomenclaturesController, type: :routing do
  routes { Curator::Engine.routes }
  let!(:default_format) { :json }
  let!(:default_id) { '1' }
  let!(:default_controller) { 'curator/controlled_terms/nomenclatures' }

  describe 'default routing' do
    Curator.controlled_terms.nomenclature_types.map(&:underscore).each do |nomenclature_type|
      describe "#{nomenclature_type} member routes" do
        include_examples 'member' do
          subject { controlled_terms_nomenclature_path(default_id, type: nomenclature_type) }
          let(:expected_controller) { default_controller }
          let(:expected_kwargs) { { id: default_id, type: nomenclature_type, format: default_format } }
        end
      end
    end
  end
end
