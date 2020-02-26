# frozen_string_literal: true

RSpec.shared_examples 'shared_get', type: :controller do |include_ark_context: false, has_collection_methods: true|
  routes { Curator::Engine.routes }
  specify { expect(format).to be_truthy.and be_a_kind_of(Symbol) }
  specify { expect(params).to be_truthy.and be_a_kind_of(Hash) }
  specify { expect(serialized_hash).to be_truthy.and be_a_kind_of(Hash) }

  let(:expected_content_type) { Mime[format].to_str }

  describe 'GET' do
    describe "#index", if: has_collection_methods do
      it "return a serialized array of json objects" do
        get :index, params: params
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq(expected_content_type)
        expect(json_response).to be_a_kind_of(Hash).and have_key(resource_key.pluralize)
        expect(json_response).to include(resource_key.pluralize => include(a_hash_including(serialized_hash)))
      end
    end

    describe "#show" do
      context 'with :id' do
        it "returns a success response" do
          id_params = params.dup
          id_params[:id] ||= resource.to_param

          get :show, params: id_params
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq(expected_content_type)
          expect(json_response).to be_a_kind_of(Hash).and have_key(resource_key)
          expect(json_response[resource_key]).to eq(serialized_hash)
        end
      end

      context 'with #ark_id as :id', if: include_ark_context do

        it "returns a success response" do
          ark_params = params.dup

          ark_params[:id] = ark_params.delete(:ark_id) if ark_params.key?(:ark_id)
          ark_params[:id] ||= resource.ark_id if resource.respond_to?(:ark_id)

          get :show, params: ark_params
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq(expected_content_type)
          expect(json_response).to be_a_kind_of(Hash).and have_key(resource_key)
          expect(json_response[resource_key]).to eq(serialized_hash)
        end
      end
    end
  end
end

RSpec.shared_examples 'shared_put_patch', type: :controller do
  routes { Curator::Engine.routes }
  pending 'Example pending until implmented properly'
end

RSpec.shared_examples 'shared_post', type: :controller do
  routes { Curator::Engine.routes }
  pending 'Example pending until implmented properly'
end


RSpec.shared_examples "shared_formats", type: :controller do |include_ark_context: false, has_collection_methods: true|
  specify { expect(serializer_class).to be_truthy.and be <= Curator::Serializers::AbstractSerializer }
  specify { expect(resource_key).to be_truthy.and be_a_kind_of(String) }
  specify { expect(base_params).to be_truthy.and be_a_kind_of(Hash) }
  specify { expect(resource).to be_truthy }

  context 'JSON(Default)' do
    let(:format) { :json }
    let(:serialized_hash) { serializer_class.new(resource, format).serializable_hash[resource_key].as_json }
    let(:params) { base_params.merge({ format: format }) }
    # NOTE: Have to add as_json so the dates match the serialized response

    include_examples 'shared_get', include_ark_context: include_ark_context
  end

  context 'XML' do
    pending 'XML Context is pending until serializers are built'
  end
end
