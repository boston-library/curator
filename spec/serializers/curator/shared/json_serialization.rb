# frozen_string_literal: true

RSpec.shared_examples 'json_serialization', type: :serializers do |include_collections: true|
  let!(:adapter_key) { :json }
  let!(:json_regex) { /[{\[]{1}([,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]|".*?")+[}\]]{1}/.freeze }

  describe 'JSON serialization behavior' do
    specify { expect(json_record).to be_truthy }
    specify { expect(expected_json).to be_a_kind_of(Proc) }
    specify if: include_collections do
      expect(json_array).to be_truthy.and respond_to(:each, :map)
    end

    describe 'For single record' do
      let!(:serializer_for_one) { described_class.new(json_record, adapter_key: adapter_key) }
      let!(:expected_json_hash) { Oj.load(expected_json.call(json_record), mode: :rails) }
      let!(:expected_json_root_key) { record_root_key(json_record) }

      describe '#serializable_hash' do
        subject { Oj.load(serializer_for_one.serialize, mode: :rails) }

        it { is_expected.to be_a_kind_of(Hash).and have_key(expected_json_root_key) }

        it 'expects subject to match :expected_json_hash' do
          expect(subject).to match(expected_json_root_key => a_hash_including(expected_json_hash[expected_json_root_key]))
        end
      end

      describe '#serialize' do
        subject { serializer_for_one.serialize }

        let!(:expected_serialized_json) { expected_json.call(json_record) }

        it { is_expected.to be_a_kind_of(String).and match(json_regex) }

        it 'expects the length of the subject to match the :expected_json' do
          expect(subject.length).to eq(expected_serialized_json.length)
        end
      end
    end

    describe 'For collection of records', if: include_collections  do
      let!(:serializer_for_many) { described_class.new(json_array, adapter_key: adapter_key) }
      let!(:expected_json_array) { Oj.load(expected_json.call(json_array), mode: :rails) }
      let!(:expected_json_root_key) { record_root_key(json_array) }

      describe '#serializable_hash' do
        subject { Oj.load(serializer_for_many.serialize) }

        it { is_expected.to be_a_kind_of(Hash).and have_key(expected_json_root_key) }

        it 'expects the root key to contain an array' do
          expect(subject[expected_json_root_key]).to be_a_kind_of(Array).and all(be_a_kind_of(Hash))
        end

        it 'expects each element of the hash to match the :expected_json_array' do
          awesome_print expected_json_array
          expect(subject[expected_json_root_key].count).to eql(expected_json_array[expected_json_root_key].count)
          expect(subject).to include(expected_json_root_key => array_including(expected_json_array[expected_json_root_key].map { |json_record| a_hash_including(json_record) }))
        end
      end

      describe '#serialize' do
        subject { serializer_for_many.serialize }

        let!(:expected_serialized_json) { expected_json.call(json_array) }

        it { is_expected.to be_a_kind_of(String).and match(json_regex) }

        it 'expects the length of the subject to match the :expected_json' do
          expect(subject.length).to eq(expected_serialized_json.length)
        end
      end
    end
  end
end
