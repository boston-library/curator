# frozen_string_literal: true

RSpec.shared_examples 'conditional_attributes', type: :lib_serializers do
  # NOTE: serializable_record should exist in the parent describe/context block
  let!(:true_conditional_params) { { conditional: true } }
  let!(:false_conditional_params) { { conditional: false } }
  let!(:nil_conditional_params) { { conditional: nil } }

  let(:if_proc) { { if: ->(_record, serializer_params) { serializer_params[:conditional] } } }
  let(:unless_proc) { { unless: ->(_record, serializer_params) { serializer_params[:conditional] } } }

  describe 'with if block' do
    subject { if_facet }

    it 'expects #include_value to return true given the params passed in' do
      expect(subject).to be_include_value(serializable_record, true_conditional_params)
    end

    it 'expects #include_value to return false given the params passed in' do
      expect(subject).not_to be_include_value(serializable_record, false_conditional_params)
      expect(subject).not_to be_include_value(serializable_record, nil_conditional_params)
    end

    it 'expects the value to be present when #serialize is called on the facet' do
      expect(serialize_facet_inst(subject, serializable_record, true_conditional_params)).to be_truthy.and be_a_kind_of(Hash).and include(subject.key => subject.serialize(serializable_record, true_conditional_params))
    end

    it 'expects the value to not be present when #serialize is called on the facet' do
      expect(serialize_facet_inst(subject, serializable_record, false_conditional_params)).to be_nil
      expect(serialize_facet_inst(subject, serializable_record, nil_conditional_params)).to be_nil
    end
  end

  describe 'with unless block' do
    subject { unless_facet }

    it 'expects #include_value to return false given the params passed in' do
      expect(subject).not_to be_include_value(serializable_record, true_conditional_params)
    end

    it 'expects #include_value to return true given the params passed in' do
      expect(subject).to be_include_value(serializable_record, false_conditional_params)
      expect(subject).to be_include_value(serializable_record, nil_conditional_params)
    end

    it 'expects the value to be present when #serialize is called on the facet' do
      expect(serialize_facet_inst(subject, serializable_record, false_conditional_params)).to be_truthy.and be_a_kind_of(Hash).and include(subject.key => subject.serialize(serializable_record, false_conditional_params))
      expect(serialize_facet_inst(subject, serializable_record, nil_conditional_params)).to be_truthy.and be_a_kind_of(Hash).and include(subject.key => subject.serialize(serializable_record, nil_conditional_params))
    end

    it 'expects the value to not be present when #serialize is called on the facet' do
      expect(serialize_facet_inst(subject, serializable_record, true_conditional_params)).to be_nil
    end
  end

  describe 'conditional precedence' do
    subject { combined_facet }

    let(:combined_conditions) { if_proc.merge(unless_proc) }

    it 'is expected to take precedence of the if_proc over the unless_proc' do
      expect(subject).to be_include_value(serializable_record, true_conditional_params)

      expect(serialize_facet_inst(subject, serializable_record, true_conditional_params)).to be_truthy.and be_a_kind_of(Hash).and include(subject.key => subject.serialize(serializable_record, true_conditional_params))
      expect(serialize_facet_inst(subject, serializable_record, false_conditional_params)).to be_nil
      expect(serialize_facet_inst(subject, serializable_record, nil_conditional_params)).to be_nil
    end
  end
end
