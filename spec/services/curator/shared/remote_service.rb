# frozen_string_literal: true

RSpec.shared_examples 'remote_service', type: :service do
  it { is_expected.to respond_to(:base_url, :pool_options, :pool_timeout, :pool_size ,:default_path_prefix, :ready?) }
end
