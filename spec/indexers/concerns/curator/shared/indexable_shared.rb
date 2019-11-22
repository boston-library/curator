# frozen_string_literal: true

RSpec.shared_context 'indexable_shared' do
  let(:solr_update_url) { "#{ENV['SOLR_URL']}/update/json?softCommit=true" }
end
