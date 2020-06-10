# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Metastreams::DescriptiveUpdaterService, type: :service do
  before(:all) do
    @digital_object ||= create(:curator_digital_object)
    @update_attributes ||= load_json_fixture('digital_object_2', 'digital_object').dig('metastreams', 'descriptive')
    VCR.use_cassette('services/metastreams/descriptive/update', record: :new_episodes) do
      @success, @result = described_class.call(@digital_object.descriptive, json_data: @update_attributes || {})
    end
  end

  describe '#call' do
    specify { expect(@success).to be_truthy }

    describe ':result' do
      subject { @result }

      let(:simple_attributes_list) { described_class.const_get(:SIMPLE_ATTRIBUTES_LIST) }
      let(:json_attributes_list) { described_class.const_get(:JSON_ATTRS) }
      let(:term_mappings_list) { described_class.const_get(:TERM_MAPPINGS) }

      specify { expect(subject).to be_valid }
      specify { expect(subject.descriptable.ark_id).to eq(@digital_object.ark_id) }

      it 'expects the simple attributes to have been updated' do
        simple_attributes_list.each do |simple_attr|
          next if !@update_attributes.key?(simple_attr)

          expect(subject.public_send(simple_attr)).to eq(@update_attributes[simple_attr])
        end
      end

      it 'expects the json attributes to have been updated' do
        json_attributes_list.each do |json_attr|
          next if !@update_attributes.key?(json_attr)

          if @update_attributes[json_attr].is_a?(Array)
            expect(subject.public_send(json_attr).count).to be >= @update_attributes[json_attr].count
          elsif @update_attributes[json_attr].is_a?(Hash)
            @update_attributes[json_attr].keys.each do |update_attr|
              expect(subject.public_send(json_attr).public_send(update_attr).as_json).to eq(@update_attributes[json_attr][update_attr])
            end
          end
        end
      end

      it 'expects the term_mappings to have been updated' do
        term_mappings_list.each do |term_mapping|
          next if !@update_attributes.key?(term_mapping)

          expect(subject.public_send(term_mapping).count).to be >= @update_attributes[term_mapping].count
        end
      end

      it 'expects the #name_roles to have been updated' do
        expect(subject.name_roles.count).to be >= @update_attributes[:name_roles].count
      end

      it 'expects the subject terms to have been updated' do
        expect(subject.subject_topics.count).to be >= @update_attributes[:subject]['topics'].count if @update_attributes.key?('topics')
        expect(subject.subject_names.count).to be >= @update_attributes[:subject]['names'].count if @update_attributes.key?('names')
        expect(subject.subject_geos).to be >= @update_attributes[:subject]['geos'].count if @update_attributes.key?('geos')
      end
    end
  end
end
