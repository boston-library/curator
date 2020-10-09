# frozen_string_literal: true

RSpec.shared_examples 'administratable', type: :model do
  it { is_expected.to have_one(:administrative).
                      inverse_of(:administratable).
                      class_name('Curator::Metastreams::Administrative').
                      dependent(:destroy).
                      autosave(true) }

  it { is_expected.to validate_presence_of(:administrative) }

  describe '#with_administrative' do
    subject { described_class }

    it 'is expected to respond_to #with_administrative' do
      expect(subject).to respond_to(:with_administrative)
    end
  end
end

RSpec.shared_examples 'descriptable', type: :model do
  it { is_expected.to have_one(:descriptive).
                      inverse_of(:digital_object).
                      class_name('Curator::Metastreams::Descriptive').
                      dependent(:destroy).
                      autosave(true) }

  it { is_expected.to validate_presence_of(:descriptive) }

  describe '#with_descriptive' do
    subject { described_class }

    it 'is expected to respond_to #with_descriptive' do
      expect(subject).to respond_to(:with_descriptive)
    end
  end
end

RSpec.shared_examples 'workflowable', type: :model do
  it { is_expected.to have_one(:workflow).
                      inverse_of(:workflowable).
                      class_name('Curator::Metastreams::Workflow').
                      dependent(:destroy).
                      autosave(true) }

  it { is_expected.to validate_presence_of(:workflow) }

  describe '#with_workflow' do
    subject { described_class }

    it 'is expected to respond_to #with_workflow' do
      expect(subject).to respond_to(:with_workflow)
    end
  end
end

RSpec.shared_examples 'metastreamable_all', type: :model do
  it_behaves_like 'administratable'
  it_behaves_like 'descriptable'
  it_behaves_like 'workflowable'

  describe '#with_metastreams' do
    subject { described_class }

    let(:expected_sql) { described_class.joins(:administrative, :descriptive, :workflow).preload(:administrative, :descriptive, :workflow).to_sql }

    it { is_expected.to respond_to(:with_metastreams) }

    it 'expects the sql for #with_metastreams to match the :expected_sql' do
      expect(subject.with_metastreams.to_sql).to match(expected_sql)
    end
  end
end

RSpec.shared_examples 'metastreamable_basic', type: :model do
  it_behaves_like 'administratable'
  it_behaves_like 'workflowable'

  describe '#with_metastreams' do
    subject { described_class }

    let(:expected_sql) { described_class.joins(:administrative, :workflow).preload(:administrative, :workflow).to_sql }

    it { is_expected.to respond_to(:with_metastreams) }

    it 'expects the sql for #with_metastreams to match the :expected_sql' do
      expect(subject.with_metastreams.to_sql).to match(expected_sql)
    end
  end
end
