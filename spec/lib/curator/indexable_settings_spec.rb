# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::IndexableSettings do
  subject { described_class.new(attrs.map { |attr| [attr, send(attr)] }.to_h) }

  let(:solr_url) { Curator.config.solr_url }
  let(:writer_class_name) { 'Traject::SolrJsonWriter' }
  let(:writer_settings) { {} }
  let(:model_name_solr_field) { 'model_name_ssi' }
  let(:solr_id_value_attribute) { 'ark_id' }
  let(:attrs) { [:solr_url, :writer_class_name, :writer_settings, :model_name_solr_field, :solr_id_value_attribute] }

  describe 'instance vars' do
    it 'sets instance vars' do
      attrs.each do |attr|
        expect(subject.instance_variable_get("@#{attr}")).to eq send(attr)
      end
    end
  end

  describe '#writer_settings' do
    it 'includes the solr_url' do
      expect(subject.writer_settings).to eq({ 'solr.url' => solr_url })
    end
  end

  describe '#writer_class' do
    it 'returns writer class' do
      expect(subject.writer_class).to eq writer_class_name.constantize
    end
  end

  describe '#writer_instance!' do
    it 'returns an instance of writer class' do
      expect(subject.writer_instance!.class.name).to eq writer_class_name
    end
  end
end
