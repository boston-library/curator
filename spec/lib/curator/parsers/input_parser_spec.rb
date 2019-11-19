# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Parsers::InputParser do
  describe '#get_proper_title' do
    it 'splits the title into nonSort and main components' do
      expect(described_class.get_proper_title('The Book of Sand')).to eq ['The ', 'Book of Sand']
      expect(described_class.get_proper_title('El libro de arena')).to eq ['El ', 'libro de arena']
      expect(described_class.get_proper_title('101 Dalmations')).to eq [nil, '101 Dalmations']
    end
  end
end
