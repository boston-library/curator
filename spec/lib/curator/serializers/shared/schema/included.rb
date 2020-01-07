# frozen_string_literal: true

RSpec.shared_examples 'included_fields', type: :lib_serializers do
  # NOTE: Expects described_schema , field_params, field_count and serializable_record to be set where example is included
  let(:serialized) { described_schema.serialize(serializable_record, field_params) }

  describe 'serialized with fields' do
    subject { serialized.fetch(:attributes, {}) }

    it 'expects only the fields to be present' do
      expect(subject.keys.count).to eq(field_count)
      expect(subject.keys).to match_array(field_params[:fields])
      expect(subject).to match(serializable_record.as_json(only: field_params[:fields]).symbolize_keys)
    end
  end
end

RSpec.shared_examples 'included_relations', type: :lib_serializers do
  pending
end
