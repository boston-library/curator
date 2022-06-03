# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::SchemaBuilders::XML do
  subject { described_class }

  it { is_expected.to be <= Curator::Serializers::SchemaBuilders::BuilderHelpers::XMLBuilder }
end
