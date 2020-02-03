# frozen_string_literal: true

RSpec.shared_examples 'json_serialization', type: :serializers do
  let(:adapter_key) { :json }
  let(:json_regex) { /\{.*\:\{.*\:.*\}\}/ }

  describe 'JSON serialization behavior' do
    describe 'For single record' do
      let(:serializer_for_one) { described_class.new(json_record, adapter_key) }
      let(:expected_json_hash) { record_as_json(json_record, expected_as_json_options) }
      let(:json_root_key) { record_root_key(json_record) }

      describe '#serializable_hash' do
        subject { serializer_for_one.serializable_hash }

        it { is_expected.to be_a_kind_of(Hash).and have_key(json_root_key) }

        it 'expects subject to match :expected_json_hash' do
          expect(subject).to match(json_root_key => a_hash_including(expected_json_hash[json_root_key]))
        end
      end

      describe '#render' do
        subject { serializer_for_one.render }

        let(:expected_json_matchers) do
          recurse_to_json_map = proc do |val|
            case val
            when Hash
              val.keys.map(&:to_json) + recurse_to_json_map.call(val.values)
            when Array
              awesome_print val
            else
              val.to_json
            end
          end
          recurse_to_json_map.call(expected_json_hash[json_root_key])
        end

        it { is_expected.to be_a_kind_of(String).and match(json_regex).and match(json_root_key) }

        it 'expects subject to match all of the expected_json_matchers' do
          expected_json_matchers.each do |json_matcher|
            awesome_print json_matcher
            awesome_print subject.match(json_matcher)
            expect(subject).to match(json_matcher)
          end
        end
      end
    end

    describe 'For collection of records' do
      let(:serializer_for_many) { described_class.new(json_array, adapter_key) }
      let(:expected_json_array) { json_array.map { |json_record| record_as_json(json_record, expected_as_json_options.merge(root: false)) }}

      describe '#serializable_hash' do
        subject { serializer_for_many.serializable_hash }

        let(:json_root_key) { record_root_key(json_array) }

        it { is_expected.to be_a_kind_of(Hash).and have_key(json_root_key) }

        it 'expects the root key to contain an array' do
          expect(subject[json_root_key]).to be_a_kind_of(Array).and all(be_a_kind_of(Hash))
        end

        it 'expects each element of the hash to match the :expected_json_array' do
          expect(subject[json_root_key].count).to eql(expected_json_array.count)
          expected_json_array.each do |json_record|
            expect(subject).to match(json_root_key => array_including(a_hash_including(json_record)))
          end
        end
      end

      describe '#render' do
        subject { serializer_for_many.render }

        let(:json_root_key) { record_root_key(json_array) }

        it { is_expected.to be_a_kind_of(String).and match(json_root_key) }
      end
    end
  end
end
