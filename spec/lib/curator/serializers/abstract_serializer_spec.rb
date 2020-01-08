# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_dsl'
RSpec.describe Curator::Serializers::AbstractSerializer, type: :lib_serializers do
  include_examples 'dsl' do
    let(:described_serializer_class) do
      Class.new(described_class) do
        schema_as_json do
          attributes :id, :updated_at, :created_at
        end
      end
    end
  end
end
