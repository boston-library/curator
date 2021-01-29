# frozen_string_literal: true

RSpec.shared_examples 'papertrailable', type: :model do
  it_behaves_like 'papertrailable_versionable'

  it 'creates versions on correct actions' do
    expect(subject.paper_trail_options[:on].sort).to eq(%i(destroy touch update))
  end
end

RSpec.shared_examples 'papertrailable_mapping', type: :model do
  it_behaves_like 'papertrailable_versionable'

  it 'creates versions on correct actions' do
    expect(subject.paper_trail_options[:on].sort).to eq(%i(create destroy update))
  end
end

RSpec.shared_examples 'papertrailable_versionable', type: :model do
  it { is_expected.to respond_to(:versions) }
end
