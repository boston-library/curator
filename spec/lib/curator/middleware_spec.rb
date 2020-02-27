# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/autoloadable'

RSpec.describe Curator::Middleware do
  it_behaves_like 'autoloadable'

  it { is_expected.to be_const_defined(:ArkOrIdConstraint) }
  it { is_expected.to be_const_defined(:StiTypesConstraint) }
  it { is_expected.to be_const_defined(:RootApp) }
end
