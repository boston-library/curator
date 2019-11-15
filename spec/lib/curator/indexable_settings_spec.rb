# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::IndexableSettings do
  let(:solr_url) { ENV['SOLR_URL'] }
  let(:writer_class_name) { 'Traject::SolrJsonWriter' }
  let(:writer_settings) { {} }
  let(:model_name_solr_field) { 'model_name_ssi' }
  let(:solr_id_value_attribute) { 'ark_id' }
  let(:attrs) { [:solr_url, :writer_class_name, :writer_settings, :model_name_solr_field, :solr_id_value_attribute] }
  let(:indexable_settings) { described_class.new(attrs.map { |attr| [attr, send(attr)] }.to_h) }

  describe 'instance vars' do
    it 'sets instance vars' do
      attrs.each do |attr|
        expect(indexable_settings.instance_variable_get("@#{attr}")).to eq send(attr)
      end
    end
  end

  describe '#writer_settings' do
    it 'includes the solr_url' do
      expect(indexable_settings.writer_settings).to eq({ 'solr.url' => solr_url })
    end
  end

  describe '#writer_class' do
    it 'returns writer class' do
      expect(indexable_settings.writer_class).to eq writer_class_name.constantize
    end
  end

  describe '#writer_instance!' do
    it 'returns an instance of writer class' do
      expect(indexable_settings.writer_instance!.class.name).to eq writer_class_name
    end
  end

  # this is set in lib/curator.rb, seems within scope to test here
  describe 'Curator.indexable_settings' do
    let(:curator_indexable_settings) { Curator.indexable_settings }

    it 'returns an instance of Curator::IndexableSettings' do
      expect(curator_indexable_settings).to be_an_instance_of(Curator::IndexableSettings)
    end

    it 'has the correct attributes' do
      expect(curator_indexable_settings.solr_url).to eq solr_url
      expect(curator_indexable_settings.writer_class_name).to eq writer_class_name
      expect(curator_indexable_settings.solr_id_value_attribute).to eq solr_id_value_attribute
    end
  end
end
