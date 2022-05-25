# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::SchemaBuilders::JSON do
  subject { described_class }

  it { is_expected.to be <= Alba::Resource }
end
