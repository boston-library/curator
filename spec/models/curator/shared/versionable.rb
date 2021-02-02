# frozen_string_literal: true

RSpec.shared_examples 'versionable', type: :model do
  it_behaves_like 'responds_to_versions'

  it 'creates versions on correct events' do
    expect(subject.paper_trail_options[:on].sort).to eq(%i(destroy touch update))
  end
end

RSpec.shared_examples 'versionable_mapping', type: :model do
  it_behaves_like 'responds_to_versions'

  it 'creates versions on correct events' do
    expect(subject.paper_trail_options[:on].sort).to eq(%i(create destroy update))
  end
end

RSpec.shared_examples 'responds_to_versions', type: :model do
  it { is_expected.to respond_to(:versions) }
end
