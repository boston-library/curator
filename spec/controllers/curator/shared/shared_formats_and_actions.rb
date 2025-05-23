# frozen_string_literal: true

RSpec.shared_examples 'shared_get', type: :controller do |include_ark_context: false, has_collection_methods: true, has_member_methods: true, resource_key: nil, file_set_type: nil|
  routes { Curator::Engine.routes }

  specify { expect(serializer_class).to be_truthy.and be <= Curator::Serializers::AbstractSerializer }
  specify { expect(resource_key).to be_truthy.and be_a_kind_of(Symbol) }
  specify { expect(format).to be_truthy.and be_a_kind_of(Symbol) }
  specify { expect(charset).to be_truthy.and be_a_kind_of(String) }
  specify { expect(params).to be_truthy.and be_a_kind_of(Hash) }
  specify { expect(serialized_hash).to be_truthy.and be_a_kind_of(Hash) }

  let(:expected_content_type) { "#{Mime[format].to_str}; #{charset}" }
  let(:pluralized_resource_key) { resource_key.to_s.pluralize.to_sym }

  describe 'GET' do
    describe "#index", if: has_collection_methods do
      it "return a serialized array of json objects" do
        resource.reload

        get :index, params: params
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq(expected_content_type)
        expect(json_response).to be_a_kind_of(Hash).and have_key(pluralized_resource_key)
        expect(json_response).to include(pluralized_resource_key => include(a_hash_including(serialized_hash)))
      end
    end

    describe "#show", if: has_member_methods do
      context 'with :id' do
        it "returns a successful response" do
          resource.reload

          id_params = params.dup
          id_params[:id] ||= resource.to_param
          get :show, params: id_params
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq(expected_content_type)
          expect(json_response).to be_a_kind_of(Hash).and have_key(resource_key)
          expect(json_response[resource_key]).to eq(serialized_hash)
        end

        context 'with :show_primary_url param', if: file_set_type == 'image' do
          before do
            described_class.send(:include, ActiveStorage::SetCurrent)
          end

          it 'returns a response with the primary_url' do
            resource.reload

            with_show_primary_params = params.dup
            with_show_primary_params[:id] ||= resource.to_param
            with_show_primary_params[:show_primary_url] = true

            get :show, params: with_show_primary_params

            expect(response).to have_http_status(:ok)
            expect(json_response).to be_a_kind_of(Hash).and have_key(resource_key)
            expect(json_response[resource_key]).to have_key(:image_primary_url)
          end
        end
      end

      context 'with invalid :id' do
        it 'returns a :not_found response' do
          invalid_id_params = params.dup
          invalid_id_params[:id] = '0'

          get :show, params: invalid_id_params
          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to eq(expected_content_type)
          expect(json_response).to be_a_kind_of(Hash).and have_key(:errors)
          expect(json_response[:errors][0]).to include(:status => 404, :title => 'Record Not Found', :detail => a_kind_of(String), :source => a_hash_including(:pointer))
        end
      end

      context 'with #ark_id as :id', if: include_ark_context do
        it "returns a successful response" do
          resource.reload

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

      context 'with invalid #ark_id as :id', if: include_ark_context do
        it "returns a :not_found response response" do
          invalid_ark_params = params.dup
          invalid_ark_params[:id] = "non-existent-namespace:#{SecureRandom.hex(4)}"

          get :show, params: invalid_ark_params
          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to eq(expected_content_type)
          expect(json_response).to be_a_kind_of(Hash).and have_key(:errors)
          expect(json_response[:errors][0]).to include(:status => 404, :title => 'Record Not Found', :detail => a_kind_of(String), :source => a_hash_including(:pointer))
        end
      end
    end
  end
end

RSpec.shared_examples 'shared_put_patch', type: :controller do |skip_put_patch: true, resource_key: nil|
  routes { Curator::Engine.routes }

  describe 'PUT/PATCH', unless: skip_put_patch do
    let(:expected_content_type) { "#{Mime[format].to_str}; #{charset}" }

    specify { expect(params).to be_truthy.and be_a_kind_of(Hash) }
    specify { expect(valid_update_attributes).to be_truthy.and be_a_kind_of(Hash) }
    specify { expect(invalid_update_attributes).to be_truthy.and be_a_kind_of(Hash) }
    specify { expect(format).to be_truthy.and be_a_kind_of(Symbol) }
    specify { expect(charset).to be_truthy.and be_a_kind_of(String) }
    specify { expect(valid_session).to be_truthy.and be_a_kind_of(Hash) }
    specify { expect(resource).to be_truthy.and be_a_kind_of(ActiveRecord::Base) }
    specify { expect(resource_key).to be_truthy.and be_a_kind_of(Symbol) }

    context 'with :valid_params' do
      let(:valid_update_params) do
        merged_params = params.dup.merge({ resource_key => valid_update_attributes })
        merged_params[:id] ||= resource.to_param
        merged_params
      end

      it 'renders a 200 JSON response with the updated resource' do
        VCR.use_cassette("controllers/#{resource_key}_update") do
          put :update, params: valid_update_params, session: valid_session
        end
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq(expected_content_type)
        expect(json_response).to be_a_kind_of(Hash).and have_key(resource_key)
        expect(json_response[resource_key]).to be_a_kind_of(Hash)
        expect(json_response[resource_key]).not_to be_empty
      end
    end

    # TODO: Figure out a way to make enums not trigger an ArgumentError when setting them to an invalid value and trigger a validation instead. This is the reason for skipping workflow from the fail clause.

    context 'with :invalid_params', if: resource_key != 'workflow' do
      let(:invalid_update_params) do
        merged_params = params.dup.merge({ resource_key => invalid_update_attributes })
        merged_params[:id] ||= resource.to_param
        merged_params
      end

      it 'returns a 422 JSON response with array of errors' do
        VCR.use_cassette("controllers/#{resource_key}_invalid_update") do
          put :update, params: invalid_update_params, session: valid_session
        end

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq(expected_content_type)
        expect(json_response).to be_a_kind_of(Hash).and have_key(:errors)
        expect(json_response[:errors][0]).to include(:status => 422, :title => 'Unprocessable Entity', :detail => a_kind_of(String), :source => a_hash_including(:pointer))
      end
    end
  end
end

RSpec.shared_examples 'shared_post', type: :controller do |skip_post: true, resource_key: nil|
  routes { Curator::Engine.routes }

  describe 'POST', unless: skip_post do
    let(:expected_content_type) { "#{Mime[format].to_str}; #{charset}" }

    specify { expect(params).to be_truthy.and be_a_kind_of(Hash) }
    specify { expect(valid_attributes).to be_truthy.and be_a_kind_of(Hash) }
    specify { expect(invalid_attributes).to be_truthy.and be_a_kind_of(Hash) }
    specify { expect(format).to be_truthy.and be_a_kind_of(Symbol) }
    specify { expect(charset).to be_truthy.and be_a_kind_of(String) }
    specify { expect(valid_session).to be_truthy.and be_a_kind_of(Hash) }
    specify { expect(resource_class).to be_truthy.and be <= ActiveRecord::Base }
    specify { expect(resource_key).to be_truthy.and be_a_kind_of(Symbol) }

    describe '#create' do
      context 'with :valid_params' do
        let(:valid_create_params) { params.dup.merge({ resource_key => valid_attributes }) }
        specify "creates #{resource_key}" do
          expect {
            VCR.use_cassette("controllers/#{resource_key}_create") do
              post :create, params: valid_create_params, session: valid_session
            end
          }.to change(resource_class, :count).by(1)
        end

        it 'renders a 201 JSON response with the new resource' do
          VCR.use_cassette("controllers/#{resource_key}_create") do
            post :create, params: valid_create_params, session: valid_session
          end

          expect(response).to have_http_status(:created)
          expect(response.content_type).to eq(expected_content_type)
          expect(json_response).to be_a_kind_of(Hash).and have_key(resource_key)
          expect(json_response[resource_key]).to be_a_kind_of(Hash)
        end
      end

      context 'with :invalid_params' do
        let(:invalid_create_params) { params.dup.merge({ resource_key => invalid_attributes }) }
        it 'returns a 422 JSON response with array of errors' do
          VCR.use_cassette("controllers/#{resource_key}_invalid_create") do
            post :create, params: invalid_create_params, session: valid_session
          end

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq(expected_content_type)
          expect(json_response).to be_a_kind_of(Hash).and have_key(:errors)
          expect(json_response[:errors][0]).to include(:status => 422, :title => 'Unprocessable Entity', :detail => a_kind_of(String), :source => a_hash_including(:pointer))
        end
      end
    end
  end
end

RSpec.shared_examples "shared_formats", type: :controller do |include_ark_context: false, has_collection_methods: true, has_member_methods: true, skip_put_patch: true, skip_post: true, resource_key: nil, file_set_type: nil, has_xml_context: false|
  specify { expect(base_params).to be_truthy.and be_a_kind_of(Hash) }
  specify { expect(resource).to be_truthy.and be_a_kind_of(ActiveRecord::Base) }

  context 'JSON(Default)' do
    let!(:format) { :json }
    let!(:charset) { 'charset=utf-8' }
    let!(:params) { base_params.dup.merge({ format: format }) }
    let(:serialized_hash) { serializer_class.new(resource.reload, adapter_key: format).serializable_hash }
    # NOTE: Have to add as_json so the dates match the serialized response

    include_examples 'shared_get', include_ark_context: include_ark_context, has_collection_methods: has_collection_methods, has_member_methods: has_member_methods, resource_key: resource_key.to_sym, file_set_type: file_set_type

    include_examples 'shared_post', skip_post: skip_post, resource_key: resource_key.to_sym

    include_examples 'shared_put_patch', skip_put_patch: skip_put_patch, resource_key: resource_key.to_sym
  end

  context 'XML', :if => has_xml_context do
    routes { Curator::Engine.routes }

    let!(:format) { :xml }
    let!(:params) { base_params.dup.merge({ format: format }) }
    let!(:charset) { 'charset=utf-8' }
    let!(:expected_content_type) { "#{Mime[format].to_str}; #{charset}" }
    let!(:xml_string) { serializer_class.new(resource.reload, adapter_key: :mods).serialize }

    describe 'GET' do
      context 'with :id' do
        it "returns a successful mods xml response" do
          resource.reload
          id_params = params.dup
          id_params[:id] ||= resource.to_param
          get :show, params: id_params

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eql(expected_content_type)
          expect(response.body).to eql(xml_string)
        end
      end

      context 'with :ark_id as :id', if: has_xml_context && include_ark_context do # This needs to check both for some reason??
        it 'returns a successful mods xml response' do
          ark_params = params.dup

          ark_params[:id] = ark_params.delete(:ark_id) if ark_params.key?(:ark_id)
          ark_params[:id] ||= resource.ark_id if resource.respond_to?(:ark_id)
          get :show, params: ark_params
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq(expected_content_type)
          expect(response.body).to eql(xml_string)
        end
      end

      context 'with invalid :id' do
        it 'returns a :not_found response as json' do
          invalid_id_params = params.dup
          invalid_id_params[:id] = '0'

          get :show, params: invalid_id_params
          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(json_response).to be_a_kind_of(Hash).and have_key(:errors)
          expect(json_response[:errors][0]).to include(:status => 404, :title => 'Record Not Found', :detail => a_kind_of(String), :source => a_hash_including(:pointer))
        end
      end
    end
  end
end
