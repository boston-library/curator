# frozen_string_literal: true

RSpec.shared_examples 'json_serialization', type: :serializers do
  let!(:adapter_key) { :json }
  let!(:json_regex) { /[{\[]{1}([,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]|".*?")+[}\]]{1}/.freeze }
  let!(:recurse_keys_to_json_map) do
    proc do |val|
      case val
      when Hash
        val.keys.map(&:to_json).concat(recurse_keys_to_json_map.call(val.values.select { |v| v.is_a?(Hash) || v.is_a?(Array) }))
      when Array
        val.flat_map { |v| recurse_keys_to_json_map.call(v) if v.is_a?(Hash) || v.is_a?(Array) }.compact
      end
    end
  end

  let!(:recurse_vals_to_json_map) do
    proc do |val|
      case val
      when Hash
        val.values.inject([]) do |ret, v|
          case v
          when Array, Hash
            ret << recurse_vals_to_json_map.call(v)
          else
            ret << v.to_json
          end
        end.flatten
      when Array
        val.flat_map { |v| recurse_vals_to_json_map.call(v) }
      else
        val.to_json
      end
    end
  end

  describe 'JSON serialization behavior' do
    specify { expect(json_record).to be_truthy }
    specify { expect(json_array).to be_truthy.and respond_to(:each, :map) }
    specify { expect(expected_as_json_options).to be_truthy.and be_a_kind_of(Hash) }

    describe 'For single record' do
      let!(:serializer_for_one) { described_class.new(json_record, adapter_key) }
      let!(:expected_json_hash) { record_as_json(json_record, expected_as_json_options) }
      let!(:json_root_key) { record_root_key(json_record) }

      describe '#serializable_hash' do
        subject { serializer_for_one.serializable_hash }

        it { is_expected.to be_a_kind_of(Hash).and have_key(json_root_key) }

        it 'expects subject to match :expected_json_hash' do
          expect(subject).to match(json_root_key => a_hash_including(expected_json_hash[json_root_key]))
        end
      end

      describe '#render' do
        subject { serializer_for_one.render }

        let!(:expected_json) { Oj.dump(expected_json_hash) }
        let!(:expected_json_key_matchers) { recurse_keys_to_json_map.call(expected_json_hash[json_root_key]) }
        let!(:expected_json_val_matchers) { recurse_vals_to_json_map.call(expected_json_hash[json_root_key]) }

        it { is_expected.to be_a_kind_of(String).and match(json_regex).and match(json_root_key) }

        it 'expects the length of the subject to match the :expected_json' do
          expect(subject.length).to eq(expected_json.length)
        end

        it 'expects subject to include all of the :expected_json_key_matchers' do
          expect(subject).to include(*expected_json_key_matchers)
        end

        it 'expects subject to match all of the :expected_json_val_matchers' do
          expect(subject).to include(*expected_json_val_matchers)
        end
      end
    end

    describe 'For collection of records' do
      let!(:serializer_for_many) { described_class.new(json_array, adapter_key) }
      let!(:expected_json_array) { json_array.map { |json_record| record_as_json(json_record, expected_as_json_options.merge(root: false)) } }

      describe '#serializable_hash' do
        subject { serializer_for_many.serializable_hash }

        let!(:json_root_key) { record_root_key(json_array) }

        it { is_expected.to be_a_kind_of(Hash).and have_key(json_root_key) }

        it 'expects the root key to contain an array' do
          expect(subject[json_root_key]).to be_a_kind_of(Array).and all(be_a_kind_of(Hash))
        end

        it 'expects each element of the hash to match the :expected_json_array' do
          expect(subject[json_root_key].count).to eql(expected_json_array.count)
          expect(subject).to include(json_root_key => array_including(expected_json_array.map { |json_record| a_hash_including(json_record) }))
        end
      end

      describe '#render' do
        subject { serializer_for_many.render }

        let!(:expected_json) { Oj.dump(Hash[json_root_key, expected_json_array]) }
        let!(:expected_json_key_matchers) { expected_json_array.map { |json_record| recurse_keys_to_json_map.call(json_record) } }
        let!(:expected_json_val_matchers) { expected_json_array.map { |json_record| recurse_vals_to_json_map.call(json_record) } }

        let!(:json_root_key) { record_root_key(json_array) }
        let!(:json_key_tally) do
          expected_json_key_matchers.flatten.inject(Hash.new(0)) do |ret, json_matcher|
            ret[json_matcher] += 1
            ret
          end.reject { |key, _v| expected_json_val_matchers.flatten.uniq.include?(key) }
        end

        let!(:json_val_tally) do
          expected_json_val_matchers.flatten.inject(Hash.new(0)) do |ret, json_matcher|
            ret[json_matcher] += 1
            ret
          end.reject { |key, _v| expected_json_key_matchers.flatten.uniq.include?(key) || key.to_i != 0 }
        end

        it { is_expected.to be_a_kind_of(String).and match(json_regex).and match(json_root_key) }

        it 'expects the length of the subject to match the :expected_json' do
          expect(subject.length).to eq(expected_json.length)
        end

        it 'expects the subject to match the key, val times in the :json_key_tally' do
          json_key_tally.each do |key, val|
            expect(subject).to match(key), "Failed on #{key}"
            expect(subject.scan(/(?=#{key})/).count).to eq(val), "failed on #{key}\nexpected: #{val}\nactual: #{subject.scan(key).count}"
          end
        end

        it 'expects the subject to match the key, val times in the :json_val_tally' do
          json_val_tally.each do |key, val|
            expect(subject).to include(key), "Failed on #{key}"
            expect(subject.scan(key).count).to eq(val), "failed on #{key}\nexpected: #{val}\nactual: #{subject.scan(key).count}"
          end
        end
      end
    end
  end
end
