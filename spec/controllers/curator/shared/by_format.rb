# frozen_string_literal: true

require_relative './by_http_verb'

RSpec.shared_examples "json_default", type: :controller do
  specify { expect(serializer_class).to be_truthy }
  context 'JSON(Default)' do
  end
end
