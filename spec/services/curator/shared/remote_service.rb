# frozen_string_literal: true

RSpec.shared_examples 'remote_service', type: :service do
  it { is_expected.to respond_to(:base_url, :base_uri, :with_client, :pool_options, :timeout_options, :default_headers, :default_path_prefix, :ssl_context) }
end
