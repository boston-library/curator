# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/autoloadable'

RSpec.describe Curator::Serializers::SchemaBuilders, type: :lib_serializers do
  it_behaves_like 'autoloadable'

  it { is_expected.to be_const_defined(:BuilderHelpers) }
  it { is_expected.to be_const_defined(:JSON) }
  it { is_expected.to be_const_defined(:XML) }
  it { is_expected.to be_const_defined(:Mods) }
end
