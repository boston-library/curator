# frozen_string_literal: true

RSpec.shared_examples 'collection', type: :routing do
  it 'routes to #index' do
    expect(:get => subject).to route_to("#{expected_controller}#index", **expected_kwargs)
  end

  it 'routes to #create' do
    expect(:post => subject).to route_to("#{expected_controller}#create", **expected_kwargs)
  end
end

RSpec.shared_examples 'member', type: :routing do
  it 'routes to #show' do
    expect(:get => subject).to route_to("#{expected_controller}#show", **expected_kwargs)
  end

  it 'routes to #update via PUT' do
    expect(:put => subject).to route_to("#{expected_controller}#update", **expected_kwargs)
  end

  it 'routes to #update via PATCH' do
    expect(:patch => subject).to route_to("#{expected_controller}#update", **expected_kwargs)
  end
end
