# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/curator_decorator'

RSpec.describe Curator::Metastreams::SubjectModsDecorator, type: :decorators do
  let!(:desc_term_counts) { 3 }
  let!(:descriptive) { create(:curator_metastreams_descriptive, :with_all_desc_terms, desc_term_count: desc_term_counts) }
  let!(:desc_subjects) { descriptive.subject.to_a }

  describe 'Base Behavior' do
    it_behaves_like 'curator_decorator' do
      let(:decorator) { described_class.new(desc_subjects.sample) }
    end

    it_behaves_like 'curator_multi_decorator' do
      let(:wrapped) { described_class.wrap_multiple(desc_subjects) }
    end
  end


  describe 'included Curator::ControlledTerms::NamePartableMods' do
    let!(:desc_subject_names) { desc_subjects.select { |sub| sub.is_a?(Curator::ControlledTerms::Name) } }

    it_behaves_like 'name_partable' do
      let(:name_partable_decorator_inst) { described_class.new(desc_subject_names.sample) }
    end
  end
end
