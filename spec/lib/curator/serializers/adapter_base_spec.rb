# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::AdapterBase, type: :lib_serializers do
  subject { described_class.new { 'I require a block!' } }

  it { is_expected.to respond_to(:schema, :root, :attribute, :attributes, :node, :meta, :link, :has_one, :belongs_to, :has_many) }

  it 'is expected to raise errors for the base class methods' do
    expect { subject.serializable_hash(nil) }.to raise_error(RuntimeError, 'Not Implemented')
    expect { subject.render(nil) }.to raise_error(RuntimeError, 'Not Implemented')
  end
end
