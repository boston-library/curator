# frozen_string_literal: true

RSpec.shared_context 'indexable_shared' do
  let(:solr_update_url) { "#{ENV['SOLR_URL']}/update/json?softCommit=true" }
  let(:institution) { create(:curator_institution) }
  let(:institution_update_request_body) do
    [{ 'id' => [institution.ark_id],
       'system_create_dtsi' => [institution.created_at.as_json],
       'system_modified_dtsi' => [institution.updated_at.as_json],
       'curator_model_ssi' => [institution.class.name],
       'curator_model_suffix_ssi' => [institution.class.name.demodulize] }].to_json
  end
end
