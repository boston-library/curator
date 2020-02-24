# frozen_string_literal: true

RSpec.shared_examples 'collection', type: :routing do
  it 'routes to #index' do
    expect(:get => subject).to route_to("#{expected_controller}#index", :format => expected_format)
  end

  it 'routes to #create' do
    expect(:post => subject).to route_to("#{expected_controller}#create", :format => expected_format)
  end
end

RSpec.shared_examples 'sti_collection', type: :routing do
  it 'routes to #index' do
    expect(:get => subject).to route_to("#{expected_controller}#index", :type => expected_type, :format => expected_format)
  end

  it 'routes to #create' do
    expect(:post => subject).to route_to("#{expected_controller}#create", :type => expected_type, :format => expected_format)
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
end


RSpec.shared_examples 'sti_member', type: :routing do
  it 'routes to #show' do
    expect(:get => subject).to route_to("#{expected_controller}#show", :id => expected_id, :type => expected_type, :format => expected_format)
  end

  it 'routes to #update via PUT' do
    expect(:put => subject).to route_to("#{expected_controller}#update", :id => expected_id,  :type => expected_type, :format => expected_format)
  end

  it 'routes to #update via PATCH' do
    expect(:patch => subject).to route_to("#{expected_controller}#update", :id => expected_id, :type => expected_type, :format => expected_format)
  end
end

RSpec.shared_examples 'metastreamable_member' do
  it 'routes to #show' do
    expect(:get => subject).to route_to("#{expected_controller}#show", :id => expected_id, :format => expected_format, :metastreamable_type => expected_metastreamable_type)
  end

  it 'routes to #update via PUT' do
    expect(:put => subject).to route_to("#{expected_controller}#update", :id => expected_id, :format => expected_format, :metastreamable_type => expected_metastreamable_type)
  end

  it 'routes to #update via PATCH' do
    expect(:patch => subject).to route_to("#{expected_controller}#update", :id => expected_id, :format => expected_format, :metastreamable_type => expected_metastreamable_type)
  end
end

RSpec.shared_examples 'sti_metastreamable_member', type: :routing do
  it 'routes to #show' do
    expect(:get => subject).to route_to("#{expected_controller}#show", :id => expected_id, :type => expected_type, :metastreamable_type => expected_metastreamable_type, :format => expected_format)
  end

  it 'routes to #update via PUT' do
    expect(:put => subject).to route_to("#{expected_controller}#update", :id => expected_id,  :type => expected_type, :metastreamable_type => expected_metastreamable_type, :format => expected_format)
  end

  it 'routes to #update via PATCH' do
    expect(:patch => subject).to route_to("#{expected_controller}#update", :id => expected_id, :type => expected_type, :metastreamable_type => expected_metastreamable_type, :format => expected_format)
  end
end
