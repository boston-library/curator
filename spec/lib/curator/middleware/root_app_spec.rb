# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Middleware::RootApp do
  subject { described_class }

  it { is_expected.to be_const_defined(:RESPONSE_BODY) }

  let!(:root_app) { described_class.new }

  describe 'instance' do
    subject { root_app }

    let(:mock_json_req) { Rack::MockRequest.env_for('/', 'HTTP_ACCEPT' => 'application/json') }
    let(:mock_xml_req) { Rack::MockRequest.env_for('/', 'HTTP_ACCEPT' => 'application/xml') }
    let(:mock_plain_text_req) { Rack::MockRequest.env_for('/', 'HTTP_ACCEPT' => 'text/plain') }
    let(:mock_other_req) { Rack::MockRequest.env_for('/', 'HTTP_ACCEPT' => 'application/rdf') }

    it { is_expected.to respond_to(:call).with(1).argument }

    describe '#call' do
      let!(:response_obj) { described_class.const_get(:RESPONSE_BODY) }
      context 'json' do
        subject { root_app.call(mock_json_req) }

        specify { expect(subject).to be_a_kind_of(Array) }

        it { is_expected.to contain_exactly(200, { 'Content-Type' => 'application/json' }, [Oj.dump(response_obj)]) }
      end

      context 'xml' do
        subject { root_app.call(mock_xml_req) }

        specify { expect(subject).to be_a_kind_of(Array) }

        it { is_expected.to contain_exactly(200, { 'Content-Type' => 'text/xml' }, [response_obj.to_xml(root: 'curator')]) }
      end

      context 'plain' do
        subject { root_app.call(mock_plain_text_req) }

        specify { expect(subject).to be_a_kind_of(Array) }

        it { is_expected.to contain_exactly(200, { 'Content-Type' => 'text/plain' }, response_obj.to_a.map { |r| "#{r.join(' ----> ')}\n" }) }
      end

      context 'default json response' do
        subject { root_app.call(mock_other_req) }

        specify { expect(subject).to be_a_kind_of(Array) }

        it { is_expected.to contain_exactly(200, { 'Content-Type' => 'application/json' }, [Oj.dump(response_obj)]) }
      end
    end
  end
end
