# frozen_string_literal: true

# ObjExtract may eventually be extracted to traject itself, these specs are based on:
# https://github.com/sciencehistory/kithe/blob/ae4f1780451b4f15577b298f57503880cc2c4681/spec/indexing/obj_extract_spec.rb
require 'rails_helper'
RSpec.describe Curator::Indexer::ObjExtract do
  let(:indexer_class) do
    Class.new(Traject::Indexer) do
      include Curator::Indexer::ObjExtract
    end
  end

  let(:indexer) { indexer_class.new("log.level": 'gt.fatal') }

  describe 'simple string attribute' do
    before(:each) do
      indexer.configure do
        to_field 'result', obj_extract('title')
      end
    end

    it 'indexes' do
      result = indexer.map_record(OpenStruct.new(title: 'title value'))
      expect(result['result']).to eq(['title value'])
    end

    it 'ignores empty string' do
      result = indexer.map_record(OpenStruct.new(title: ''))
      expect(result['result']).to be_nil
      expect(result.keys).not_to include('result')
    end

    it 'indexes false' do
      result = indexer.map_record(OpenStruct.new(title: false))
      expect(result['result']).to eq([false])
    end
  end

  describe 'primitive array attribute' do
    before(:each) do
      indexer.configure do
        to_field 'result', obj_extract('title')
      end
    end

    it 'indexes empty value' do
      result = indexer.map_record(OpenStruct.new(title: []))
      expect(result).to eq({})
    end

    it 'indexes single value' do
      result = indexer.map_record(OpenStruct.new(title: ['foo']))
      expect(result).to eq({ 'result' => ['foo'] })
    end

    it 'indexes multiple values' do
      result = indexer.map_record(OpenStruct.new(title: ['title value1', 'title value2']))
      expect(result['result']).to eq(['title value1', 'title value2'])
    end

    it 'filters out empty strings' do
      result = indexer.map_record(OpenStruct.new(title: ['value1', 'value2', '', '']))
      expect(result['result']).to eq(['value1', 'value2'])
    end

    it 'ignores all empty string value' do
      result = indexer.map_record(OpenStruct.new(title: ['', '']))
      expect(result['result']).to be_nil
      expect(result.keys).not_to include('result')
    end

    it 'allows false values' do
      result = indexer.map_record(OpenStruct.new(title: [false]))
      expect(result['result']).to eq([false])
    end
  end

  describe 'model attribute' do
    before(:each) do
      indexer.configure do
        to_field 'result', obj_extract(:creator, :name)
      end
    end

    it 'indexes single' do
      result = indexer.map_record(OpenStruct.new(creator: OpenStruct.new(type: 'engraver', name: 'Doe, Jane')))
      expect(result).to eq({ 'result' => ['Doe, Jane'] })
    end

    it 'indexes nil without raising' do
      result = indexer.map_record(OpenStruct.new(creator: nil))
      expect(result).to eq({})
    end

    it 'ignores empty string' do
      result = indexer.map_record(OpenStruct.new(creator: OpenStruct.new(type: 'engraver', name: '')))
      expect(result['result']).to be_nil
      expect(result.keys).not_to include('result')
    end

    describe 'as array' do
      it 'indexes empty' do
        result = indexer.map_record(OpenStruct.new(creator: []))
        expect(result).to eq({})
      end

      it 'indexes single element' do
        result = indexer.map_record(OpenStruct.new(creator: [OpenStruct.new(type: 'engraver', name: 'Doe, Jane')]))
        expect(result).to eq({ 'result' => ['Doe, Jane'] })
      end

      it 'indexes multiple' do
        result = indexer.map_record(
          OpenStruct.new(
            creator: [
                OpenStruct.new(type: 'engraver', name: 'Doe, Jane'),
                OpenStruct.new(type: 'engraver', name: 'Tame, Puddin'),
            ]
          )
        )
        expect(result).to eq({ 'result' => ['Doe, Jane', 'Tame, Puddin'] })
      end

      it 'ignores empty string' do
        result = indexer.map_record(OpenStruct.new(creator: [OpenStruct.new(type: 'engraver', name: '')]))
        expect(result['result']).to be_nil
        expect(result.keys).not_to include('result')
      end
    end

    describe 'does not respond to' do
      it 'raises' do
        expect do
          indexer.map_record(Struct.new(:other_attribute).new)
        end.to raise_error(NoMethodError)
      end
    end
  end

  describe 'hash' do
    before(:each) do
      indexer.configure do
        to_field 'result', obj_extract(:creator, :name)
      end
    end

    it 'indexes single' do
      result = indexer.map_record(OpenStruct.new(creator: { type: 'engraver', name: 'Doe, Jane' }))
      expect(result).to eq({ 'result' => ['Doe, Jane'] })
    end

    it 'indexes array value' do
      result = indexer.map_record(OpenStruct.new(creator: [
          { type: 'engraver', name: 'Doe, Jane' }, { type: 'illustrator', name: 'Tame, Puddin' }
      ]))
      expect(result).to eq({ 'result' => ['Doe, Jane', 'Tame, Puddin'] })
    end

    it 'indexes nil' do
      result = indexer.map_record(OpenStruct.new(creator: nil))
      expect(result).to eq({})
    end

    it 'indexes empty array' do
      result = indexer.map_record(OpenStruct.new(creator: []))
      expect(result).to eq({})
    end

    it 'ignores empty string' do
      result = indexer.map_record(OpenStruct.new(creator: { type: 'engraver', name: '' }))
      expect(result['result']).to be_nil
      expect(result.keys).not_to include('result')
    end
  end
end
