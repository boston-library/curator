# frozen_string_literal: true

RSpec.shared_context 'indexable_shared' do
  let(:solr_update_url) { "#{Curator.config.solr_url}/update/json?softCommit=true" }

  def body_for_update_request(model)
    [
      { 'id' => [model.ark_id],
        'system_create_dtsi' => [model.created_at.to_s(:iso8601)],
        'system_modified_dtsi' => [model.updated_at.to_s(:iso8601)],
        'curator_model_ssi' => [model.class.name],
        'curator_model_suffix_ssi' => [model.class.name.demodulize] }
    ].to_json
  end
end
