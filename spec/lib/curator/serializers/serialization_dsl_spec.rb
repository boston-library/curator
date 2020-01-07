# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_dsl'
RSpec.describe Curator::Serializers::SerializationDSL, type: :lib_serializer do
  let!(:fail_inheritance_class) { Class.new }

  describe 'included' do
    it 'expects to raise error if included in anything other than the Abstract Serializer Class' do
      expect do
        Class.new do
          include Curator::Serializers::SerializationDSL
        end
      end.to raise_error(RuntimeError, /is not inherited from Curator::Serializers::AbstractSerializer/)
    end
  end

  describe 'inherited' do
    it 'expects to raise error if inherited from anything other than the Abstract Serializer Class' do
      expect { Class.new(fail_inheritance_class.include(described_class)) }.to raise_error(RuntimeError, /is not inherited from Curator::Serializers::AbstractSerializer/)
    end

    include_examples 'dsl' do
      let(:described_serializer_class) do
        Class.new(Curator::Serializers::AbstractSerializer) do
          schema_as_json do
            attributes :id
          end
        end
      end
    end
  end
end
