# frozen_string_literal: true

RSpec.shared_examples 'collection', type: :routing do
  it 'routes to #index' do
    expect(:get => subject).to route_to("#{expected_controller}#index", :format => expected_format)
  end

  it 'routes to #create' do
    expect(:post => subject).to route_to("#{expected_controller}#create", :format => expected_format)
  end
end


RSpec.shared_examples 'member', type: :routing do
  it 'routes to #show' do
    expect(:get => subject).to route_to("#{expected_controller}#show", :id => expected_id, :format => expected_format)
  end

  it 'routes to #update via PUT' do
    expect(:put => subject).to route_to("#{expected_controller}#update", :id => expected_id, :format => expected_format)
  end

  it 'routes to #update via PATCH' do
    expect(:patch => subject).to route_to("#{expected_controller}#update", :id => expected_id, :format => expected_format)
  end

  skip 'routes to #destroy' do
    expect(:delete => subject).to route_to("#{expected_controller}#destroy", :id => expected_id, :format => expected_format)
  end
end
