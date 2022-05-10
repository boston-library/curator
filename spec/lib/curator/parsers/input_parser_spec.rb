# not using frozen_string_literal here since we're modifying strings

require 'rails_helper'

RSpec.describe Curator::Parsers::InputParser do
  describe '#get_proper_title' do
    it 'splits the title into nonSort and main components' do
      expect(described_class.get_proper_title('The Book of Sand')).to eq ['The ', 'Book of Sand']
      expect(described_class.get_proper_title('El libro de arena')).to eq ['El ', 'libro de arena']
      expect(described_class.get_proper_title('101 Dalmations')).to eq [nil, '101 Dalmations']
    end
  end

  describe '#corp_name_part_splitter' do
    pending 'TODO'
  end

  describe '#pers_name_part_splitter' do
    pending 'TODO'
  end

  describe '#utf8_encode' do
    it 'encodes the string as utf-8' do
      ascii_string = 'hello'.force_encoding('ASCII')
      expect(described_class.utf8_encode(ascii_string).encoding.to_s).to eq 'UTF-8'
    end

    it 'removes extra whitespace and line breaks' do
      bad_string = " Lorem ipsum dolor\namet     ullamco  "
      expect(described_class.utf8_encode(bad_string)).to eq 'Lorem ipsum dolor amet ullamco'
    end

    it 'removes HTML tags' do
      bad_string = "<strong>Lorem</strong> <em>ipsum</em> <a href='foo'>dolor</a>"
      expect(described_class.utf8_encode(bad_string)).to eq 'Lorem ipsum dolor'
    end
  end

  describe '#clean_text' do
    it 'removes Zooniverse transcription markup' do
      zoo_string = 'a sad [deletion][unclear][/deletion] one to you.'
      expect(described_class.clean_text(zoo_string)).to eq 'a sad one to you.'
    end
  end
end
