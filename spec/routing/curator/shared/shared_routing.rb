# frozen_string_literal: true

RSpec.shared_examples 'collection', type: :routing do |read_only: false|
  specify { expect(subject).to be_truthy.and be_a_kind_of(String) }
  specify { expect(expected_kwargs).to be_truthy.and be_a_kind_of(Hash) }

  it 'routes to #index' do
    expect(:get => subject).to route_to("#{expected_controller}#index", **expected_kwargs)
  end

  it 'routes to #create', unless: read_only do
    expect(:post => subject).to route_to("#{expected_controller}#create", **expected_kwargs)
  end
end

RSpec.shared_examples 'member', type: :routing do |read_only: false|
  specify { expect(subject).to be_truthy.and be_a_kind_of(String) }
  specify { expect(expected_kwargs).to be_truthy.and be_a_kind_of(Hash) }

  it 'routes to #show' do
    expect(:get => subject).to route_to("#{expected_controller}#show", **expected_kwargs)
  end

  it 'routes to #update via PUT', unless: read_only do
    expect(:put => subject).to route_to("#{expected_controller}#update", **expected_kwargs)
  end

  it 'routes to #update via PATCH', unless: read_only do
    expect(:patch => subject).to route_to("#{expected_controller}#update", **expected_kwargs)
  end
end
