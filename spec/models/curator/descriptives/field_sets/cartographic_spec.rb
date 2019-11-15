# frozen_string_literal: true

require 'rails_helper'
require_relative '../../shared/descriptives/field_set'
RSpec.describe Curator::Descriptives::Cartographic, type: :model do
  subject { create(:curator_descriptives_cartographic) }

  it_behaves_like 'field_set'

  describe 'attributes' do
    it { is_expected.to respond_to(:scale, :projection) }

    describe 'attr_json settings' do
      let(:scale_type) { described_class.attr_json_registry.fetch(:scale, nil)&.type }
      let(:projection_type) { described_class.attr_json_registry.fetch(:projection, nil)&.type }
      it 'expects the attributes to have the following types' do
        expect(scale_type).to be_a_kind_of(AttrJson::Type::Array)
        expect(scale_type&.base_type).to be_a_kind_of(ActiveModel::Type::String)
        expect(projection_type).to be_a_kind_of(ActiveModel::Type::String)
      end

      it 'expects the attributes to have types that match values' do
        expect(subject.scale).to be_a_kind_of(Array).and all(be_an_instance_of(String))
        expect(subject.projection).to be_an_instance_of(String)
      end
    end
  end
end
